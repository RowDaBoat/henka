# @deps std
from std/strutils import contains, startsWith, parseBiggestInt
from std/intsets import IntSet, initIntSet, containsOrIncl
# @deps slate
import slate/ast as astTF
# @deps henka
import ./[common, clang, pragmas, comments]


proc toNimEnum*(conv: var Converter, cursor: CXCursor, name: string, config: EnumConfig): cint =
  let commentOpt = conv.add_comment(cursor)
  let labelKind = if conv.isCpp and clang_EnumDecl_isScoped(cursor) != 0: EnumClass else: EnumType
  let enumName = conv.addRenamed(labelKind, name)
  var valueCtx = ChildCtx(conv: addr conv)

  discard clang_visitChildren(
    cursor,
    proc(child: CXCursor, parent: CXCursor, data: pointer): cint {.cdecl.} =
      if clang_getCursorKind(child) == CXCursor_EnumConstantDecl:
        let ctx       = cast[ptr ChildCtx](data)
        if not ctx.conv[].symbolFilter(EnumValue, child.spelling):
          return CXChildVisit_Continue.cint
        let valName   = ctx.conv[].addRenamed(EnumValue, child.spelling)
        let valNum    = clang_getEnumConstantDeclValue(child)
        let valLoc    = ctx.conv[].addSrc($valNum)
        let valExpr   = ctx.conv[].ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.integer, value: valLoc)))
        let bindingId = ctx.conv[].ast.add_binding(Binding(name: some(valName), value: some(valExpr), private: true))
        ctx.ids.add bindingId
      return CXChildVisit_Continue.cint
    ,
    addr valueCtx
  )

  var seenOrdinals = initIntSet()
  var firstField: Option[astTF.Id] = none(astTF.Id)
  var lastField: Option[astTF.Id] = none(astTF.Id)
  var firstDupe: Option[astTF.Id] = none(astTF.Id)
  var lastDupe: Option[astTF.Id] = none(astTF.Id)

  for bindingId in valueCtx.ids:
    let binding = conv.ast.data.bindings[bindingId]
    let valueExpr = conv.ast.data.expressions[binding.value.get]
    let valueLoc = valueExpr.literal.value
    let valueStr = conv.ast.data.modules[conv.module].source[valueLoc.start ..< valueLoc.`end`]
    let ordinal = parseBiggestInt(valueStr).int
    if seenOrdinals.containsOrIncl(ordinal):
      if lastDupe.isSome: conv.ast.data.bindings[lastDupe.get].next = some(bindingId)
      if firstDupe.isNone: firstDupe = some(bindingId)
      lastDupe = some(bindingId)
    else:
      if lastField.isSome: conv.ast.data.bindings[lastField.get].next = some(bindingId)
      if firstField.isNone: firstField = some(bindingId)
      lastField = some(bindingId)

  let pragmaId = conv.enumPragmas(name, config)
  let typeId = conv.ast.add_type(Type(kind: astTF.tEnumeration, enumeration: TypeEnum(
    name: some(enumName), values: firstField, pragmas: some(pragmaId)
  )))
  conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: typeId, comment: commentOpt)))

  let sanitizedEnumName = conv.sanitizer(conv.renamer(labelKind, name))

  var currentDupe = firstDupe
  while currentDupe.isSome:
    let dupeId = currentDupe.get
    let nextDupe = conv.ast.data.bindings[dupeId].next
    let existingValue = conv.ast.data.bindings[dupeId].value.get
    let enumNameExpr = conv.ast.add_expression(Expression(kind: astTF.eIdentifier, identifier: ExpressionIdentifier(name: conv.addName(sanitizedEnumName))))
    let argBinding = conv.ast.add_binding(Binding(value: some(existingValue), private: true))
    let castCall = conv.ast.add_expression(Expression(kind: astTF.eCall, call: ExpressionCall(name: enumNameExpr, arguments: some(argBinding))))
    let enumTypeRef = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName(sanitizedEnumName))))
    let enumTypeExpr = conv.ast.add_expression_type(enumTypeRef)
    conv.ast.data.bindings[dupeId].value = some(castCall)
    conv.ast.data.bindings[dupeId].dataType = some(enumTypeExpr)
    conv.ast.data.bindings[dupeId].private = false
    conv.ast.data.bindings[dupeId].next = none(astTF.Id)
    conv.add_statement_chained(Statement(kind: astTF.sVariable, variable: StatementVariable(id: dupeId)))
    currentDupe = nextDupe

  let cleanAlias = conv.sanitizer(conv.renamer(Typedef, name))
  if cleanAlias notin conv.seenTypedefs and cleanAlias != sanitizedEnumName:
    let cleanName    = conv.addRenamed(Typedef, name)
    let refTypeId    = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName(sanitizedEnumName))))
    let cleanAliasId = conv.ast.add_type(Type(kind: astTF.tAlias, alias: TypeAlias(name: some(cleanName), target: refTypeId)))
    conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: cleanAliasId)))

  return CXChildVisit_Continue.cint


proc toCintEnum*(conv: var Converter, cursor: CXCursor, name: string, config: EnumConfig): cint =
  let commentOpt      = conv.add_comment(cursor)
  let enumIdent       = conv.addRenamed(EnumType, name)
  let distinctKeyword = case EnumOption.Distinct in config.options
    of on:  some(conv.addName("distinct"))
    of off: none(astTF.Identifier)
  let cintTypeId      = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName("cint"), keyword: distinctKeyword)))
  let enumAliasId     = conv.ast.add_type(Type(kind: astTF.tAlias, alias: TypeAlias(name: some(enumIdent), target: cintTypeId)))
  conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: enumAliasId, comment: commentOpt)))

  let sanitizedEnumName = conv.sanitizer(conv.renamer(EnumType, name))
  var ectx = ChildCtx(conv: addr conv, name: sanitizedEnumName, isDistinct: EnumOption.Distinct in config.options)

  discard clang_visitChildren(
    cursor,
    proc(child: CXCursor, parent: CXCursor, data: pointer): cint {.cdecl.} =
      if clang_getCursorKind(child) == CXCursor_EnumConstantDecl:
        let ctx         = cast[ptr ChildCtx](data)
        if not ctx.conv[].symbolFilter(EnumValue, child.spelling):
          return CXChildVisit_Continue.cint
        let valName     = ctx.conv[].addRenamed(EnumValue, child.spelling)
        let valNum      = clang_getEnumConstantDeclValue(child)
        let valLoc      = ctx.conv[].addSrc($valNum)
        let valExpr     = ctx.conv[].ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.integer, value: valLoc)))
        let value       = case ctx.isDistinct
          of off: valExpr
          of on:
            let enumNameExpr = ctx.conv[].ast.add_expression(Expression(kind: astTF.eIdentifier, identifier: ExpressionIdentifier(name: ctx.conv[].addName(ctx.name))))
            let argBinding   = ctx.conv[].ast.add_binding(Binding(value: some(valExpr), private: true))
            ctx.conv[].ast.add_expression(Expression(kind: astTF.eCall, call: ExpressionCall(name: enumNameExpr, arguments: some(argBinding))))
        let enumTypeRef  = ctx.conv[].ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: ctx.conv[].addName(ctx.name))))
        let enumTypeExpr = ctx.conv[].ast.add_expression_type(enumTypeRef)
        let bindingId   = ctx.conv[].ast.add_binding(Binding(name: some(valName), dataType: some(enumTypeExpr), value: some(value)))
        ctx.conv[].add_statement_chained(Statement(kind: astTF.sVariable, variable: StatementVariable(id: bindingId)))
      return CXChildVisit_Continue.cint
    ,
    addr ectx
  )

  let cleanAlias = conv.sanitizer(conv.renamer(Typedef, name))
  if cleanAlias notin conv.seenTypedefs and cleanAlias != sanitizedEnumName:
    let cleanName    = conv.addRenamed(Typedef, name)
    let refTypeId    = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName(sanitizedEnumName))))
    let cleanAliasId = conv.ast.add_type(Type(kind: astTF.tAlias, alias: TypeAlias(name: some(cleanName), target: refTypeId)))
    conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: cleanAliasId)))

  return CXChildVisit_Continue.cint


type AnonCtx = object
  conv*    : ptr Converter
  typed*   : bool

proc toAnonEnum*(conv: var Converter, cursor: CXCursor, typed: bool = true): cint =
  var ctx = AnonCtx(conv: addr conv, typed: typed)
  discard clang_visitChildren(
    cursor,
    proc(child: CXCursor, parent: CXCursor, data: pointer): cint {.cdecl.} =
      if clang_getCursorKind(child) == CXCursor_EnumConstantDecl:
        let ctx         = cast[ptr AnonCtx](data)
        if not ctx.conv[].symbolFilter(EnumValue, child.spelling):
          return CXChildVisit_Continue.cint
        let valName     = ctx.conv[].addRenamed(EnumValue, child.spelling)
        let valNum      = clang_getEnumConstantDeclValue(child)
        let valLoc      = ctx.conv[].addSrc($valNum)
        let valExpr     = ctx.conv[].ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.integer, value: valLoc)))
        let dataType    = case ctx.typed
          of off: none(astTF.Id)
          of on:
            let cintTypeRef  = ctx.conv[].ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: ctx.conv[].addName("cint"))))
            some(ctx.conv[].ast.add_expression_type(cintTypeRef))
        let bindingId   = ctx.conv[].ast.add_binding(Binding(name: some(valName), dataType: dataType, value: some(valExpr)))
        ctx.conv[].add_statement_chained(Statement(kind: astTF.sVariable, variable: StatementVariable(id: bindingId)))
      return CXChildVisit_Continue.cint
    ,
    addr ctx
  )
  return CXChildVisit_Continue.cint


proc toBitflagEnum*(conv: var Converter, cursor: CXCursor, name: string, config: EnumConfig): cint =
  raise newException(Defect, "EnumMode.Bitflag is not implemented yet")

proc toConstEnum*(conv: var Converter, cursor: CXCursor, name: string, config: EnumConfig): cint =
  conv.toAnonEnum(cursor, typed = false)


proc toEnum*(conv: var Converter, cursor: CXCursor, name: string): cint =
  let isAnonymous = name.len == 0 or name.contains("unnamed") or name.contains("anonymous")
  if isAnonymous:
    return conv.toAnonEnum(cursor)

  if name in conv.seenEnums:
    return CXChildVisit_Continue.cint
  conv.seenEnums.incl name

  let isScoped = conv.isCpp and clang_EnumDecl_isScoped(cursor) != 0
  let labelKind = if isScoped: EnumClass else: EnumType
  let baseMode = if isScoped: EnumMode.Enum else: conv.enumMode
  let enumConfig = conv.enumModeSelect(name, labelKind, EnumConfig(mode: baseMode, options: conv.enumOptions))

  result = case enumConfig.mode
    of EnumMode.Cint:    conv.toCintEnum(cursor, name, enumConfig)
    of EnumMode.Enum:    conv.toNimEnum(cursor, name, enumConfig)
    of EnumMode.Bitflag: conv.toBitflagEnum(cursor, name, enumConfig)
    of EnumMode.Const:   conv.toConstEnum(cursor, name, enumConfig)
    of EnumMode.Default: raise newException(Defect, "EnumMode.Default must be resolved before toEnum")

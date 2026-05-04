# @deps std
from std/strutils import contains, startsWith
# @deps slate
import slate/ast as astTF
# @deps henka
import ./[common, clang, pragmas, comments]


proc toNimEnum*(conv: var Converter, cursor: CXCursor, name: string): cint =
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
        let valName   = ctx.conv[].addName(child.spelling)
        let valNum    = clang_getEnumConstantDeclValue(child)
        let valLoc    = ctx.conv[].addSrc($valNum)
        let valExpr   = ctx.conv[].ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.integer, value: valLoc)))
        let bindingId = ctx.conv[].ast.add_binding(Binding(name: some(valName), value: some(valExpr), private: true))
        ctx.ids.add bindingId
      return CXChildVisit_Continue.cint
    ,
    addr valueCtx
  )

  var firstValue: Option[astTF.Id] = none(astTF.Id)
  if valueCtx.ids.len > 0:
    for idx in 0..<valueCtx.ids.len - 1:
      conv.ast.data.bindings[valueCtx.ids[idx]].next = some(valueCtx.ids[idx + 1])
    firstValue = some(valueCtx.ids[0])

  let qualified = if conv.isCpp: cursor.qualifiedName else: name
  let pragmaId = conv.chainPragmas(@[
    (conv.importPragmaKey, "\"" & qualified & "\""),
    conv.headerPragma
  ])
  let typeId = conv.ast.add_type(Type(kind: astTF.tEnumeration, enumeration: TypeEnum(
    name: some(enumName), values: firstValue, pragmas: some(pragmaId)
  )))
  conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: typeId, comment: commentOpt)))

  return CXChildVisit_Continue.cint


proc toCintEnum*(conv: var Converter, cursor: CXCursor, name: string): cint =
  let commentOpt = conv.add_comment(cursor)
  let enumIdent       = conv.addRenamed(EnumType, name)
  let cintTypeId      = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName("cint"))))
  let enumAliasId     = conv.ast.add_type(Type(kind: astTF.tAlias, alias: TypeAlias(name: some(enumIdent), target: cintTypeId)))
  conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: enumAliasId, comment: commentOpt)))

  let sanitizedEnumName = conv.sanitizer(conv.renamer(EnumType, name))
  var ectx = ChildCtx(conv: addr conv, name: sanitizedEnumName)

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
        let enumTypeRef  = ctx.conv[].ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: ctx.conv[].addName(ctx.name))))
        let enumTypeExpr = ctx.conv[].ast.add_expression_type(enumTypeRef)
        let bindingId   = ctx.conv[].ast.add_binding(Binding(name: some(valName), dataType: some(enumTypeExpr), value: some(valExpr)))
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


proc toAnonEnum*(conv: var Converter, cursor: CXCursor): cint =
  discard clang_visitChildren(
    cursor,
    proc(child: CXCursor, parent: CXCursor, data: pointer): cint {.cdecl.} =
      if clang_getCursorKind(child) == CXCursor_EnumConstantDecl:
        let conv        = cast[ptr Converter](data)
        if not conv[].symbolFilter(EnumValue, child.spelling):
          return CXChildVisit_Continue.cint
        let valName     = conv[].addRenamed(EnumValue, child.spelling)
        let valNum      = clang_getEnumConstantDeclValue(child)
        let valLoc      = conv[].addSrc($valNum)
        let valExpr     = conv[].ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.integer, value: valLoc)))
        let cintTypeRef  = conv[].ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv[].addName("cint"))))
        let cintTypeExpr = conv[].ast.add_expression_type(cintTypeRef)
        let bindingId   = conv[].ast.add_binding(Binding(name: some(valName), dataType: some(cintTypeExpr), value: some(valExpr)))
        conv[].add_statement_chained(Statement(kind: astTF.sVariable, variable: StatementVariable(id: bindingId)))
      return CXChildVisit_Continue.cint
    ,
    addr conv
  )
  return CXChildVisit_Continue.cint


proc toBitflagEnum*(conv: var Converter, cursor: CXCursor, name: string): cint =
  raise newException(Defect, "EnumMode.Bitflag is not implemented yet")

proc toConstEnum*(conv: var Converter, cursor: CXCursor, name: string): cint =
  raise newException(Defect, "EnumMode.Const is not implemented yet")


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
    of EnumMode.Cint:    conv.toCintEnum(cursor, name)
    of EnumMode.Enum:    conv.toNimEnum(cursor, name)
    of EnumMode.Bitflag: conv.toBitflagEnum(cursor, name)
    of EnumMode.Const:   conv.toConstEnum(cursor, name)
    of EnumMode.Default: raise newException(Defect, "EnumMode.Default must be resolved before toEnum")

# @deps std
from std/strutils import join, startsWith, find, contains
# @deps slate
import slate/ast as astTF
# @deps henka
import ./[clang, common, comments, pragmas, types]


proc linkAfter*(conv: var Converter, previousId: astTF.Id, nextId: astTF.Id) =
  var previous = conv.ast.data.statements[previousId]
  case previous.kind
  of astTF.sVariable    : previous.variable.next    = some(nextId)
  of astTF.sType        : previous.`type`.next      = some(nextId)
  of astTF.sAlias       : previous.alias.next       = some(nextId)
  of astTF.sProcedure   : previous.procedure.next   = some(nextId)
  of astTF.sComment     : previous.comment.next     = some(nextId)
  of astTF.sImport      : previous.`import`.next    = some(nextId)
  of astTF.sPassthrough : previous.passthrough.next = some(nextId)
  of astTF.sPragma      : previous.pragma.next      = some(nextId)
  of astTF.sExpression  : previous.expression.next  = some(nextId)
  of astTF.sKeyword     : previous.keyword.next     = some(nextId)
  of astTF.sBranch      : previous.branch.next      = some(nextId)
  conv.ast.data.statements[previousId] = previous

proc isTypeStatement(kind: astTF.StatementKind): bool =
  kind in {astTF.sType, astTF.sAlias}

proc add_statement_chained*(conv: var Converter, statement: astTF.Statement): astTF.Id {.discardable.} =
  let stmtId = conv.ast.add_statement(statement)

  if statement.kind.isTypeStatement:
    if conv.lastTypeStmt.isSome:
      conv.linkAfter(conv.lastTypeStmt.get, stmtId)
    if conv.firstTypeStmt.isNone:
      conv.firstTypeStmt = some(stmtId)
    conv.lastTypeStmt = some(stmtId)
  else:
    if conv.lastOtherStmt.isSome:
      conv.linkAfter(conv.lastOtherStmt.get, stmtId)
    if conv.firstOtherStmt.isNone:
      conv.firstOtherStmt = some(stmtId)
    conv.lastOtherStmt = some(stmtId)

  result = stmtId


proc toAlias*(conv: var Converter, cursor: CXCursor, name: string): cint =
  let underlying = clang_getTypedefDeclUnderlyingType(cursor)
  if underlying.kind == CXType_Elaborated:
    var elabName = underlying.typeSpelling
 
    # Skip typedef that aliases same-named struct/enum (e.g. typedef struct Foo {} Foo)
    if   elabName.startsWith("struct "):
      elabName = elabName[7..^1]
    elif elabName.startsWith("enum "):
      elabName = elabName[5..^1]

    if elabName == name:
      return CXChildVisit_Continue.cint

    # Anonymous struct typedef: emit as incompleteStruct object with the typedef name
    if ' ' in elabName:
      let commentOpt = conv.add_comment(cursor)
      let typeName = conv.addRenamed(Typedef, name)
      var anonPairs :seq[(system.string, system.string)]= @[("incompleteStruct", "")]

      if conv.linkMode != LinkMode.dynlib:
        anonPairs.add (conv.importPragmaKey, "\"" & name & "\"")
        anonPairs.add conv.headerPragma

      let pragmaId = conv.chainPragmas(anonPairs)
      let typeId = conv.ast.add_type(Type(kind: astTF.tObject, `object`: TypeObject(name: some(typeName), pragmas: some(pragmaId))))
      conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: typeId, comment: commentOpt)))

      return CXChildVisit_Continue.cint

  let commentOpt = conv.add_comment(cursor)
  let targetId  = conv.convertType(underlying)
  let aliasName = conv.addRenamed(Typedef, name)
  let aliasId   = conv.ast.add_type(Type(kind: astTF.tAlias, alias: TypeAlias(name: some(aliasName), target: targetId)))
  conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: aliasId, comment: commentOpt)))

  result = CXChildVisit_Continue.cint


proc toObject*(conv: var Converter, cursor: CXCursor, name: string, isUnion: bool = false): cint

proc emitUnnamedInnerType*(conv: var Converter, innerCursor: CXCursor, parentName: string, fieldIndex: int, isUnion: bool): astTF.Id =
  let syntheticName = parentName & "_unnamed" & $fieldIndex
  let labelKind = if isUnion: UnionType else: StructType
  let typeName = conv.addRenamed(labelKind, syntheticName)

  var innerCtx = ChildCtx(conv: addr conv, name: syntheticName)
  discard clang_visitChildren(
    innerCursor,
    proc(child: CXCursor, parent: CXCursor, data: pointer): cint {.cdecl.} =
      if clang_getCursorKind(child) == CXCursor_FieldDecl:
        let ctx         = cast[ptr ChildCtx](data)
        let rawName     = child.spelling
        let fieldLabel  = if rawName.len > 0: rawName else: ctx.conv[].unnamedFieldNamer(ctx.name, ctx.ids.len)
        let fieldName   = ctx.conv[].addRenamed(Field, fieldLabel)
        let fieldTypeId = ctx.conv[].convertType(clang_getCursorType(child))
        let bindingId   = ctx.conv[].ast.add_binding(Binding(name: some(fieldName), dataType: some(fieldTypeId)))
        ctx.ids.add bindingId
      return CXChildVisit_Continue.cint
    ,
    addr innerCtx
  )

  var firstField: Option[astTF.Id] = none(astTF.Id)
  if innerCtx.ids.len > 0:
    for idx in 0..<innerCtx.ids.len - 1:
      conv.ast.data.bindings[innerCtx.ids[idx]].next = some(innerCtx.ids[idx + 1])
    firstField = some(innerCtx.ids[0])

  let pragmaId = conv.structPragmas(syntheticName, isForward = false, isTagged = false, isUnion = isUnion)
  let keywordIdent = case isUnion
    of on:  some(conv.addName("union"))
    of off: none(astTF.Identifier)
  let typeId = conv.ast.add_type(Type(kind: astTF.tObject, `object`: TypeObject(name: some(typeName), fields: firstField, pragmas: some(pragmaId), keyword: keywordIdent)))
  conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: typeId)))

  let renamedRef = conv.addRenamed(labelKind, syntheticName)
  result = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: renamedRef)))


proc collectFields(conv: var Converter, cursor: CXCursor, name: string): seq[astTF.Id] =
  var ctx = ChildCtx(conv: addr conv, name: name)
  discard clang_visitChildren(
    cursor,
    proc(child: CXCursor, parent: CXCursor, data: pointer): cint {.cdecl.} =
      let ctx       = cast[ptr ChildCtx](data)
      let childKind = clang_getCursorKind(child)

      if childKind == CXCursor_StructDecl or childKind == CXCursor_UnionDecl:
        let childIsUnion = childKind == CXCursor_UnionDecl
        let childName = child.spelling
        let isAnonymous = childName.contains("anonymous")
        let isUnnamed = childName.contains("unnamed")

        if isAnonymous:
          discard clang_visitChildren(
            child,
            proc(innerChild: CXCursor, innerParent: CXCursor, innerData: pointer): cint {.cdecl.} =
              if clang_getCursorKind(innerChild) == CXCursor_FieldDecl:
                let innerCtx    = cast[ptr ChildCtx](innerData)
                let rawName     = innerChild.spelling
                let fieldLabel  = if rawName.len > 0: rawName else: innerCtx.conv[].unnamedFieldNamer(innerCtx.name, innerCtx.ids.len)
                let fieldName   = innerCtx.conv[].addRenamed(Field, fieldLabel)
                let fieldTypeId = innerCtx.conv[].convertType(clang_getCursorType(innerChild))
                let bindingId   = innerCtx.conv[].ast.add_binding(Binding(name: some(fieldName), dataType: some(fieldTypeId)))
                innerCtx.ids.add bindingId
              return CXChildVisit_Continue.cint
            ,
            data
          )
        elif isUnnamed:
          let syntheticTypeId = ctx.conv[].emitUnnamedInnerType(child, ctx.name, ctx.ids.len, childIsUnion)
          ctx.pendingTypeId = some(syntheticTypeId)
        else:
          discard ctx.conv[].toObject(child, childName, childIsUnion)

      elif childKind == CXCursor_FieldDecl:
        let rawName     = child.spelling
        let fieldLabel  = if rawName.len > 0: rawName else: ctx.conv[].unnamedFieldNamer(ctx.name, ctx.ids.len)
        let fieldName   = ctx.conv[].addRenamed(Field, fieldLabel)
        let fieldTypeId = if ctx.pendingTypeId.isSome:
          let pending = ctx.pendingTypeId.get
          ctx.pendingTypeId = none(astTF.Id)
          pending
        else:
          ctx.conv[].convertType(clang_getCursorType(child))
        let bindingId = ctx.conv[].ast.add_binding(Binding(name: some(fieldName), dataType: some(fieldTypeId)))
        ctx.ids.add bindingId

      return CXChildVisit_Continue.cint
    ,
    addr ctx
  )
  result = ctx.ids


proc buildObjectType(conv: var Converter, name: string, fieldIds: seq[astTF.Id], isTagged: bool, isUnion: bool, isForward: bool): Type =
  let labelKind = if isUnion: UnionType else: StructType
  let structName = case isTagged
    of true:  conv.addRenamed(labelKind, name)
    of false: conv.addRenamed(Typedef, name)

  var firstField: Option[astTF.Id] = none(astTF.Id)
  if fieldIds.len > 0:
    for idx in 0..<fieldIds.len - 1:
      conv.ast.data.bindings[fieldIds[idx]].next = some(fieldIds[idx + 1])
    firstField = some(fieldIds[0])

  let pragmaId = conv.structPragmas(name, isForward, isTagged, isUnion)
  let keywordIdent = case isUnion
    of on:  some(conv.addName("union"))
    of off: none(astTF.Identifier)

  result = Type(kind: astTF.tObject, `object`: TypeObject(name: some(structName), fields: firstField, pragmas: some(pragmaId), keyword: keywordIdent))


proc toObject*(conv: var Converter, cursor: CXCursor, name: string, isUnion: bool = false): cint =
  if name.len == 0 or ' ' in name:
    return CXChildVisit_Continue.cint

  let typeSpelling = clang_getCursorType(cursor).typeSpelling
  let isTagged = typeSpelling.startsWith("struct ") or typeSpelling.startsWith("union ")
  let labelKind = if isUnion: UnionType else: StructType

  if name in conv.seenStructs:
    let (existingTypeId, originalModule) = conv.seenStructs[name]
    let savedModule = conv.module
    conv.module = originalModule
    let fieldIds = conv.collectFields(cursor, name)
    if fieldIds.len == 0:
      conv.module = savedModule
      return CXChildVisit_Continue.cint
    let replacementType = conv.buildObjectType(name, fieldIds, isTagged, isUnion, isForward = false)
    conv.ast.data.types[existingTypeId] = replacementType
    conv.module = savedModule
    return CXChildVisit_Continue.cint

  let fieldIds = conv.collectFields(cursor, name)
  let isForward = fieldIds.len == 0

  let commentOpt = conv.add_comment(cursor)
  let objectType = conv.buildObjectType(name, fieldIds, isTagged, isUnion, isForward)
  let typeId = conv.ast.add_type(objectType)
  conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: typeId, comment: commentOpt)))
  conv.seenStructs[name] = (typeId, conv.module)

  if isTagged:
    let cleanName        = conv.addRenamed(Typedef, name)
    let renamedStructRef = conv.addRenamed(labelKind, name)
    let refTypeId        = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: renamedStructRef)))
    let aliasTypeId      = conv.ast.add_type(Type(kind: astTF.tAlias, alias: TypeAlias(name: some(cleanName), target: refTypeId)))
    conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: aliasTypeId)))

  return CXChildVisit_Continue.cint


proc toScopedEnum*(conv: var Converter, cursor: CXCursor, name: string): cint =
  let commentOpt = conv.add_comment(cursor)
  let enumName = conv.addRenamed(EnumClass, name)
  var valueCtx = ChildCtx(conv: addr conv)

  discard clang_visitChildren(
    cursor,
    proc(child: CXCursor, parent: CXCursor, data: pointer): cint {.cdecl.} =
      if clang_getCursorKind(child) == CXCursor_EnumConstantDecl:
        let ctx       = cast[ptr ChildCtx](data)
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

  let qualified = cursor.qualifiedName
  let pragmaId = conv.chainPragmas(@[
    ("importcpp", "\"" & qualified & "\""),
    conv.headerPragma
  ])
  let typeId = conv.ast.add_type(Type(kind: astTF.tEnumeration, enumeration: TypeEnum(
    name: some(enumName), values: firstValue, pragmas: some(pragmaId)
  )))
  conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: typeId, comment: commentOpt)))

  return CXChildVisit_Continue.cint


proc toEnum*(conv: var Converter, cursor: CXCursor, name: string): cint =
  let isAnonymous = name.len == 0 or name.contains("unnamed") or name.contains("anonymous")
  if isAnonymous:
    discard clang_visitChildren(
      cursor,
      proc(child: CXCursor, parent: CXCursor, data: pointer): cint {.cdecl.} =
        if clang_getCursorKind(child) == CXCursor_EnumConstantDecl:
          let conv        = cast[ptr Converter](data)
          let valName     = conv[].addRenamed(EnumValue, child.spelling)
          let valNum      = clang_getEnumConstantDeclValue(child)
          let valLoc      = conv[].addSrc($valNum)
          let valExpr     = conv[].ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.integer, value: valLoc)))
          let cintTypeRef = conv[].ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv[].addName("cint"))))
          let bindingId   = conv[].ast.add_binding(Binding(name: some(valName), dataType: some(cintTypeRef), value: some(valExpr)))
          conv[].add_statement_chained(Statement(kind: astTF.sVariable, variable: StatementVariable(id: bindingId)))
        return CXChildVisit_Continue.cint
      ,
      addr conv
    )
    return CXChildVisit_Continue.cint

  if name in conv.seenEnums:
    return CXChildVisit_Continue.cint

  conv.seenEnums.incl name
  if conv.isCpp and clang_EnumDecl_isScoped(cursor) != 0:
    return conv.toScopedEnum(cursor, name)

  let commentOpt = conv.add_comment(cursor)

  # C enum -> cint alias + constants (C enums are just integers)
  let enumIdent       = conv.addRenamed(EnumType, name)
  let cintTypeId      = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName("cint"))))
  let enumAliasId     = conv.ast.add_type(Type(kind: astTF.tAlias, alias: TypeAlias(name: some(enumIdent), target: cintTypeId)))
  conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: enumAliasId, comment: commentOpt)))

  # Generate constants for each enum value
  let sanitizedEnumName = conv.sanitizer(conv.renamer(EnumType, name))
  var ectx = ChildCtx(conv: addr conv, name: sanitizedEnumName)

  discard clang_visitChildren(
    cursor,
    proc(child: CXCursor, parent: CXCursor, data: pointer): cint {.cdecl.} =
      if clang_getCursorKind(child) == CXCursor_EnumConstantDecl:
        let ctx         = cast[ptr ChildCtx](data)
        let valName     = ctx.conv[].addRenamed(EnumValue, child.spelling)
        let valNum      = clang_getEnumConstantDeclValue(child)
        let valLoc      = ctx.conv[].addSrc($valNum)
        let valExpr     = ctx.conv[].ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.integer, value: valLoc)))
        let enumTypeRef = ctx.conv[].ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: ctx.conv[].addName(ctx.name))))
        let bindingId   = ctx.conv[].ast.add_binding(Binding(name: some(valName), dataType: some(enumTypeRef), value: some(valExpr)))
        ctx.conv[].add_statement_chained(Statement(kind: astTF.sVariable, variable: StatementVariable(id: bindingId)))
      return CXChildVisit_Continue.cint
    ,
    addr ectx
  )

  # Clean alias: WGPUFoo = enum_WGPUFoo
  # Skip if a typedef with the same sanitized name already exists (e.g. dearimgui pattern:
  # `typedef int ImGuiWindowFlags_;` + `enum ImGuiWindowFlags_ {}` both produce `ImGuiWindowFlags`)
  if name notin conv.seenSymbols:
    let cleanName    = conv.addRenamed(Typedef, name)
    let refTypeId    = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName(sanitizedEnumName))))
    let cleanAliasId = conv.ast.add_type(Type(kind: astTF.tAlias, alias: TypeAlias(name: some(cleanName), target: refTypeId)))
    conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: cleanAliasId)))

  return CXChildVisit_Continue.cint


proc toProcedure*(conv: var Converter, cursor: CXCursor, name: string): cint =
  let nimName  = if name.startsWith("operator"): operatorName(name) else: name
  let funcName = conv.addRenamed(Proc, nimName)
  let funcType = clang_getCursorType(cursor)
  let retType  = clang_getResultType(funcType)
  let retOpt   = if retType.kind == CXType_Void: none(astTF.Id) else: some(conv.convertType(retType))
  let argc     = clang_Cursor_getNumArguments(cursor)
  var argIds :seq[astTF.Id]= @[]

  for idx in 0..<argc:
    let arg       = clang_Cursor_getArgument(cursor, idx.cuint)
    let argName   = if arg.spelling.len > 0: arg.spelling else: "a" & $idx
    let argIdent  = conv.addRenamed(Parameter, argName)
    let argTypeId = conv.convertType(clang_getCursorType(arg))
    let bindingId = conv.ast.add_binding(Binding(name: some(argIdent), dataType: some(argTypeId), private: true))
    argIds.add bindingId

  var firstArg :Option[astTF.Id]= none(astTF.Id)

  if argIds.len > 0:
    for idx in 0..<argIds.len - 1:
      conv.ast.data.bindings[argIds[idx]].next = some(argIds[idx + 1])
    firstArg = some(argIds[0])

  let importName = if conv.isCpp: cursor.qualifiedName else: name
  var pragmaId   = conv.funcPragmas(importName)

  if clang_Cursor_isVariadic(cursor) != 0:
    let varargsId = conv.addPragma("varargs")
    conv.ast.data.pragmas[varargsId].next = some(pragmaId)
    pragmaId = varargsId

  let commentOpt = conv.add_comment(cursor)
  let procId = conv.ast.add_procedure(Procedure(
    name: some(funcName), arguments: firstArg, returnType: retOpt,
    impure: true, pragmas: some(pragmaId)
  ))

  conv.add_statement_chained(Statement(kind: astTF.sProcedure, procedure: StatementProcedure(id: procId, comment: commentOpt)))

  return CXChildVisit_Continue.cint


proc toVariable*(conv: var Converter, cursor: CXCursor, name: string): cint =
  let varName    = conv.addRenamed(Variable, name)
  let cursorType = clang_getCursorType(cursor)
  var typeStr    = cursorType.typeSpelling
  let isConst    = typeStr.startsWith("const ")

  if isConst:
    typeStr = typeStr[6..^1]

  let varTypeId  = conv.convertType(cursorType)

  # Try to evaluate the initializer
  var valueOpt :Option[astTF.Id]= none(astTF.Id)
  let evalResult = clang_Cursor_Evaluate(cursor)

  if not evalResult.isNil:
    let evalKind = clang_EvalResult_getKind(evalResult)
    if evalKind == CXEval_Int:
      let val     = clang_EvalResult_getAsLongLong(evalResult)
      let valLoc  = conv.addSrc($val)
      let valExpr = conv.ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.integer, value: valLoc)))
      valueOpt    = some(valExpr)
    elif evalKind == CXEval_Float:
      let val     = clang_EvalResult_getAsDouble(evalResult)
      let valLoc  = conv.addSrc($val)
      let valExpr = conv.ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.float, value: valLoc)))
      valueOpt    = some(valExpr)

    clang_EvalResult_dispose(evalResult)

  let hasValue  = valueOpt.isSome
  let bindingId = conv.ast.add_binding(Binding(
    name     : some(varName),
    dataType : some(varTypeId),
    value    : valueOpt,
    runtime  : not (isConst and hasValue),
    mutable  : not isConst))

  conv.add_statement_chained(Statement(kind: astTF.sVariable, variable: StatementVariable(id: bindingId)))

  return CXChildVisit_Continue.cint


const compilerDirectives * = ["_Pragma", "__attribute__", "__declspec", "__asm__", "__asm", "__volatile__"]

proc isCompilerDirective(value :system.string) :bool =
  for directive in compilerDirectives:
    if value.find(directive) >= 0: return true

  return false


proc toMacro*(conv: var Converter, cursor: CXCursor, name: string): cint =
  if name.startsWith("_") or name.startsWith("__"):
    return CXChildVisit_Continue.cint

  if clang_Cursor_isMacroFunctionLike(cursor) != 0:
    return CXChildVisit_Continue.cint

  let extent              = clang_getCursorExtent(cursor)
  var tokens: ptr CXToken = nil
  var numTokens: cuint    = 0

  clang_tokenize(conv.tu, extent, addr tokens, addr numTokens)

  if numTokens > 1:
    var valueParts :seq[string]= @[]

    for idx in 1..<numTokens:
      let token = cast[ptr CXToken](cast[uint](tokens) + idx.uint * sizeof(CXToken).uint)[]
      let spelling = clang_getTokenSpelling(conv.tu, token)
      let text = $clang_getCString(spelling)
      clang_disposeString(spelling)
      valueParts.add text

    let value = valueParts.join(" ")
    if value.len > 0:
      if value.isCompilerDirective:
        let passthroughText = "# #define " & name & " " & value
        let passthroughLoc = conv.addSrc(passthroughText)
        conv.add_statement_chained(Statement(kind: astTF.sPassthrough, passthrough: StatementPassthrough(location: passthroughLoc)))
      else:
        let mapped      = if conv.valueMapper != nil: conv.valueMapper(value) else: value
        let nameIdent   = conv.addRenamed(Constant, name)
        let targetIdent = conv.addName(mapped)
        let aliasId     = conv.ast.add_alias(Alias(name: nameIdent, target: some(targetIdent)))
        conv.add_statement_chained(Statement(kind: astTF.sAlias, alias: StatementAlias(id: aliasId)))

  if not tokens.isNil:
    clang_disposeTokens(conv.tu, tokens, numTokens)

  return CXChildVisit_Continue.cint

# @deps std
from std/strutils import startsWith
# @deps slate
import slate/ast as astTF
# @deps henka
import ./[clang, common, comments, pragmas, types, statements]


proc toMethod     *(conv :var Converter; cursor :CXCursor; name :string) :cint
proc toConstructor*(conv :var Converter; cursor :CXCursor; name :string) :cint
proc toDestructor *(conv :var Converter; cursor :CXCursor; name :string) :cint



proc operatorInfo*(name :system.string; argc :cint; cursor :CXCursor) :(system.string, system.string)=
  if name == "operator=":
    var isMove = false
    if argc > 0:
      let argType = clang_getCursorType(clang_Cursor_getArgument(cursor, 0))
      if argType.kind == CXType_RValueReference: isMove = true
    if isMove : result = ("move", "\"# = std::move(#)\"")
    else      : result = ("assign", "\"# = #\"")
    return
  if name == "operator-":
    if argc == 0 : result = ("`-`", "\"-#\"")
    else         : result = ("`-`", "\"# - #\"")
    return
  for entry in OperatorPatterns:
    if entry[0] == name:
      result = (entry[1], entry[2])
      return
  result = (name, "\"#." & name & "(@)\"")


proc toClass*(conv :var Converter; cursor :CXCursor; name :string) :cint=
  if name.len == 0 or ' ' in name: return CXChildVisit_Continue.cint
  if name in conv.seenStructs: return CXChildVisit_Continue.cint
  let commentOpt = conv.add_comment(cursor)
  if commentOpt.isSome:
    conv.add_statement_chained(Statement(kind: astTF.sComment, comment: StatementComment(id: commentOpt.get)))
  let className = conv.addName(name)
  # Collect public fields
  var ctx = ChildCtx(conv: addr conv)
  discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
    let ctx = cast[ptr ChildCtx](data)
    let childKind = clang_getCursorKind(child)
    if childKind == CXCursor_CXXAccessSpecifier:
      ctx.name = (if clang_getCXXAccessSpecifier(child) == CX_CXXPublic: "public" else: "private")
    elif childKind == CXCursor_FieldDecl and ctx.name == "public":
      let rawName     = child.spelling
      let fieldLabel  = if rawName.len > 0: rawName else: ctx.conv[].unnamedFieldNamer("", ctx.ids.len)
      let fieldName   = ctx.conv[].addRenamed(Field, fieldLabel)
      let fieldTypeId = ctx.conv[].convertType(clang_getCursorType(child))
      let bindingId   = ctx.conv[].ast.add_binding(Binding(name: some(fieldName), dataType: some(fieldTypeId)))
      ctx.ids.add bindingId
    return CXChildVisit_Continue.cint
  , addr ctx)
  var firstField :Option[astTF.Id]= none(astTF.Id)
  if ctx.ids.len > 0:
    for idx in 0..<ctx.ids.len - 1:
      conv.ast.data.bindings[ctx.ids[idx]].next = some(ctx.ids[idx + 1])
    firstField = some(ctx.ids[0])
  # Collect base classes as links
  type BaseCtx = object
    conv :ptr Converter
    link_ids :seq[astTF.Id]
  var baseCtx = BaseCtx(conv: addr conv)
  discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
    if clang_getCursorKind(child) == CXCursor_CXXBaseSpecifier:
      let ctx        = cast[ptr BaseCtx](data)
      let referenced = clang_getCursorReferenced(child)
      let baseTypeId = ctx.conv[].ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: ctx.conv[].addName(referenced.spelling))))
      ctx.link_ids.add ctx.conv[].ast.add_link(Link(`type`: baseTypeId))
    return CXChildVisit_Continue.cint
  , addr baseCtx)
  var linkRange :Option[astTF.Location]= none(astTF.Location)
  if baseCtx.link_ids.len > 0:
    linkRange = some(astTF.Location(start: baseCtx.link_ids[0].uint64, `end`: baseCtx.link_ids[^1].uint64))
  # A class is forward-declared only if it has no fields, no base classes, and no methods
  var hasMembers = false
  discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
    let childKind = clang_getCursorKind(child)
    if childKind in {CXCursor_FieldDecl.cint, CXCursor_CXXMethod.cint, CXCursor_Constructor.cint, CXCursor_Destructor.cint, CXCursor_CXXBaseSpecifier.cint}:
      cast[ptr bool](data)[] = true
    return CXChildVisit_Continue.cint
  , addr hasMembers)
  let isForward = not hasMembers
  let pragmaId = conv.classPragmas(cursor, isForward)
  # Only mark inheritable if the class declares virtual methods and has no base class
  var hasVirtual = false
  discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
    if clang_getCursorKind(child) != CXCursor_CXXMethod: return CXChildVisit_Continue.cint
    if clang_CXXMethod_isPureVirtual(child) == 0: return CXChildVisit_Continue.cint
    cast[ptr bool](data)[] = true
  , addr hasVirtual)
  if not hasVirtual and baseCtx.link_ids.len == 0:
    discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
      if clang_getCursorKind(child) != CXCursor_CXXMethod: return CXChildVisit_Continue.cint
      if clang_CXXMethod_isVirtual(child) == 0: return CXChildVisit_Continue.cint
      cast[ptr bool](data)[] = true
    , addr hasVirtual)
  var finalPragma = pragmaId
  if hasVirtual and baseCtx.link_ids.len == 0:
    let inheritableId = conv.addPragma("inheritable")
    conv.ast.data.pragmas[inheritableId].next = some(pragmaId)
    finalPragma = inheritableId
  let typeId = conv.ast.add_type(Type(kind: astTF.tObject, `object`: TypeObject(name: some(className), fields: firstField, pragmas: some(finalPragma), link: linkRange)))
  conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: typeId)))
  conv.seenStructs[name] = typeId
  # Now emit methods, constructors, destructors
  discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
    let conv = cast[ptr Converter](data)
    let childKind = clang_getCursorKind(child)
    case childKind
    of CXCursor_Constructor : discard conv[].toConstructor(child, child.spelling)
    of CXCursor_Destructor  : discard conv[].toDestructor(child, child.spelling)
    of CXCursor_CXXMethod   : discard conv[].toMethod(child, child.spelling)
    else                    : discard
    return CXChildVisit_Continue.cint
  , addr conv)
  return CXChildVisit_Continue.cint


proc toMethod*(conv :var Converter; cursor :CXCursor; name :string) :cint=
  let isStatic   = clang_CXXMethod_isStatic(cursor) != 0
  let isOperator = name.startsWith("operator")
  let funcType   = clang_getCursorType(cursor)
  let retType    = clang_getResultType(funcType)
  let retOpt     = if retType.kind == CXType_Void: none(astTF.Id) else: some(conv.convertType(retType))
  # Build arguments
  let argc   = clang_Cursor_getNumArguments(cursor)
  var argIds :seq[astTF.Id]= @[]
  if not isStatic:
    let isConst      = clang_CXXMethod_isConst(cursor) != 0
    let parentCursor = clang_getCursorSemanticParent(cursor)
    let parentTypeId = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName(parentCursor.spelling), mutable: not isConst)))
    let thisBinding  = conv.ast.add_binding(Binding(name: some(conv.addName("this")), dataType: some(parentTypeId), private: true))
    argIds.add thisBinding
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
  # Build pragma and name
  var pragmaId :astTF.Id
  var procName :astTF.Identifier
  if isOperator:
    let operatorArgCount   = argc  # not counting implicit this
    let (nimName, pattern) = operatorInfo(name, operatorArgCount.cint, cursor)
    procName = conv.addRenamed(Proc, nimName)
    let isAssignmentOp = name in ["operator=", "operator+=", "operator-=", "operator*=", "operator/=", "operator%=", "operator<<=", "operator>>=", "operator&=", "operator|=", "operator^="]
    var pragmaPairs    :seq[(system.string, system.string)]= @[("importcpp", pattern)]
    if isAssignmentOp: pragmaPairs.add ("discardable", "")
    pragmaPairs.add conv.linkPragma
    pragmaId = conv.chainPragmas(pragmaPairs)
  elif isStatic:
    procName = conv.addRenamed(Proc, name)
    pragmaId = conv.staticMethodPragmas(cursor)
  else:
    procName = conv.addRenamed(Proc, name)
    pragmaId = conv.methodPragmas(cursor)
  let procId = conv.ast.add_procedure(Procedure(
    name       : some(procName),
    arguments  : firstArg,
    returnType : retOpt,
    impure     : true,
    pragmas    : some(pragmaId)))
  conv.add_statement_chained(Statement(kind: astTF.sProcedure, procedure: StatementProcedure(id: procId)))
  return CXChildVisit_Continue.cint


proc toConstructor*(conv :var Converter; cursor :CXCursor; name :string) :cint=
  let parentCursor = clang_getCursorSemanticParent(cursor)
  let parentName   = parentCursor.spelling
  let retTypeId    = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName(parentName))))
  let argc = clang_Cursor_getNumArguments(cursor)
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
  let pragmaId = conv.constructorPragmas(cursor)
  let procName = conv.addRenamed(Proc, conv.constructorName(parentName))
  let procId   = conv.ast.add_procedure(Procedure(
    name       : some(procName),
    arguments  : firstArg,
    returnType : some(retTypeId),
    impure     : true,
    pragmas    : some(pragmaId)))
  conv.add_statement_chained(Statement(kind: astTF.sProcedure, procedure: StatementProcedure(id: procId)))
  return CXChildVisit_Continue.cint


proc toDestructor*(conv :var Converter; cursor :CXCursor; name :string) :cint=
  let parentCursor = clang_getCursorSemanticParent(cursor)
  let parentName   = parentCursor.spelling
  let parentTypeId = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName(parentName), mutable: true)))
  let thisBinding  = conv.ast.add_binding(Binding(name: some(conv.addName("this")), dataType: some(parentTypeId), private: true))
  let pragmaId     = conv.destructorPragmas(cursor)
  let procName     = conv.addRenamed(Proc, conv.destructorName(parentName))
  let procId       = conv.ast.add_procedure(Procedure(
    name      : some(procName),
    arguments : some(thisBinding),
    impure    : true,
    pragmas   : some(pragmaId)))
  conv.add_statement_chained(Statement(kind: astTF.sProcedure, procedure: StatementProcedure(id: procId)))
  return CXChildVisit_Continue.cint


proc toClassTemplate*(conv :var Converter; cursor :CXCursor; name :string) :cint=
  if name.len == 0 or ' ' in name: return CXChildVisit_Continue.cint
  if name in conv.seenStructs: return CXChildVisit_Continue.cint
  let className = conv.addName(name)
  # Collect template type parameters
  var templateCtx = ChildCtx(conv: addr conv)
  discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
    if clang_getCursorKind(child) == CXCursor_TemplateTypeParameter:
      let ctx       = cast[ptr ChildCtx](data)
      let paramName = ctx.conv[].addName(child.spelling)
      let bindingId = ctx.conv[].ast.add_binding(Binding(name: some(paramName), private: true))
      ctx.ids.add bindingId
    return CXChildVisit_Continue.cint
  , addr templateCtx)
  var firstGeneric :Option[astTF.Id]= none(astTF.Id)
  if templateCtx.ids.len > 0:
    for idx in 0..<templateCtx.ids.len - 1:
      conv.ast.data.bindings[templateCtx.ids[idx]].next = some(templateCtx.ids[idx + 1])
    firstGeneric = some(templateCtx.ids[0])
  # Collect fields
  var fieldCtx = ChildCtx(conv: addr conv)
  discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
    if clang_getCursorKind(child) == CXCursor_FieldDecl:
      let ctx         = cast[ptr ChildCtx](data)
      let fieldName   = ctx.conv[].addRenamed(Field, child.spelling)
      let fieldTypeId = ctx.conv[].convertType(clang_getCursorType(child))
      let bindingId   = ctx.conv[].ast.add_binding(Binding(name: some(fieldName), dataType: some(fieldTypeId)))
      ctx.ids.add bindingId
    return CXChildVisit_Continue.cint
  , addr fieldCtx)
  var firstField :Option[astTF.Id]= none(astTF.Id)
  if fieldCtx.ids.len > 0:
    for idx in 0..<fieldCtx.ids.len - 1:
      conv.ast.data.bindings[fieldCtx.ids[idx]].next = some(fieldCtx.ids[idx + 1])
    firstField = some(fieldCtx.ids[0])
  let pragmaId = conv.classPragmas(cursor, false)
  let typeId   = conv.ast.add_type(Type(kind: astTF.tObject, `object`: TypeObject(name: some(className), fields: firstField, generics: firstGeneric, pragmas: some(pragmaId))))
  conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: typeId)))
  conv.seenStructs[name] = typeId
  return CXChildVisit_Continue.cint


proc toFunctionTemplate*(conv :var Converter; cursor :CXCursor; name :string) :cint=
  let funcName = conv.addRenamed(Proc, name)
  let qualified = cursor.qualifiedName
  let funcType = clang_getCursorType(cursor)
  let retType  = clang_getResultType(funcType)
  let retOpt   = if retType.kind == CXType_Void: none(astTF.Id) else: some(conv.convertType(retType))
  # Collect template type parameters
  var genericCtx = ChildCtx(conv: addr conv)
  discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
    if clang_getCursorKind(child) == CXCursor_TemplateTypeParameter:
      let ctx       = cast[ptr ChildCtx](data)
      let paramName = ctx.conv[].addName(child.spelling)
      let bindingId = ctx.conv[].ast.add_binding(Binding(name: some(paramName), private: true))
      ctx.ids.add bindingId
    return CXChildVisit_Continue.cint
  , addr genericCtx)
  var firstGeneric :Option[astTF.Id]= none(astTF.Id)
  if genericCtx.ids.len > 0:
    for idx in 0..<genericCtx.ids.len - 1:
      conv.ast.data.bindings[genericCtx.ids[idx]].next = some(genericCtx.ids[idx + 1])
    firstGeneric = some(genericCtx.ids[0])
  # Collect arguments via children (clang_Cursor_getNumArguments returns -1 for templates)
  var argCtx = ChildCtx(conv: addr conv)
  discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
    if clang_getCursorKind(child) == CXCursor_ParmDecl:
      let ctx       = cast[ptr ChildCtx](data)
      let argName   = if child.spelling.len > 0: child.spelling else: "a" & $ctx.ids.len
      let argIdent  = ctx.conv[].addRenamed(Parameter, argName)
      let argTypeId = ctx.conv[].convertType(clang_getCursorType(child))
      let bindingId = ctx.conv[].ast.add_binding(Binding(name: some(argIdent), dataType: some(argTypeId), private: true))
      ctx.ids.add bindingId
    return CXChildVisit_Continue.cint
  , addr argCtx)
  var firstArg :Option[astTF.Id]= none(astTF.Id)
  if argCtx.ids.len > 0:
    for idx in 0..<argCtx.ids.len - 1:
      conv.ast.data.bindings[argCtx.ids[idx]].next = some(argCtx.ids[idx + 1])
    firstArg = some(argCtx.ids[0])
  let pragmaId = conv.chainPragmas(@[
    ("importcpp", "\"" & qualified & "<'*0>(@)\""),
    conv.linkPragma])
  let procId = conv.ast.add_procedure(Procedure(
    name       : some(funcName),
    generics   : firstGeneric,
    arguments  : firstArg,
    returnType : retOpt,
    impure     : true,
    pragmas    : some(pragmaId)))
  conv.add_statement_chained(Statement(kind: astTF.sProcedure, procedure: StatementProcedure(id: procId)))
  return CXChildVisit_Continue.cint


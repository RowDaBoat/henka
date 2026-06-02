# @deps std
from std/strutils import startsWith, contains, strip, IdentChars
# @deps nonim
import nonim/ast as astTF
# @deps henka
import ./[clang, common, comments, pragmas, types, statements, enums]


const AllocationOperators = ["operator new", "operator new[]", "operator delete", "operator delete[]"]


proc toMethod     *(conv :var Converter; cursor :CXCursor; name :string) :cint
proc toConstructor*(conv :var Converter; cursor :CXCursor; name :string) :cint
proc toDestructor *(conv :var Converter; cursor :CXCursor; name :string) :cint


proc signatureUsesSimdRegister(conv :Converter; cursor :CXCursor) :bool=
  let funcType = clang_getCursorType(cursor)
  if conv.usesSimdRegister(clang_getResultType(funcType)): return true
  let argc = clang_Cursor_getNumArguments(cursor)
  for idx in 0..<argc:
    let arg = clang_Cursor_getArgument(cursor, idx.cuint)
    if conv.usesSimdRegister(clang_getCursorType(arg)): return true
  result = false


proc emitSkipNote(conv :var Converter; text :string)=
  let commentId = conv.add_comment(text, isDoc = false)
  conv.add_statement_chained(Statement(kind: astTF.sComment, comment: StatementComment(id: commentId)))


proc skipSimdRegister(conv :var Converter; cursor :CXCursor; name :string) :cint=
  conv.emitSkipNote("Skipped " & name & " (SIMD register type)  (" & cursor.sourceLocation & ")")
  result = CXChildVisit_Continue.cint


proc operatorInfo*(name :system.string; argc :cint; cursor :CXCursor) :(system.string, system.string)=
  if name == "operator=":
    var isMove = false
    if argc > 0:
      let argType = clang_getCursorType(clang_Cursor_getArgument(cursor, 0))
      if argType.kind == CXType_RValueReference: isMove = true
    if isMove : result = ("move", "# = std::move(#)")
    else      : result = ("assign", "# = #")
    return
  if name == "operator-":
    if argc == 0 : result = ("`-`", "-#")
    else         : result = ("`-`", "# - #")
    return
  for entry in OperatorPatterns:
    if entry[0] == name:
      result = (entry[1], entry[2])
      return
  let target = stripNamespace(name["operator".len .. ^1].strip)
  if target.len > 0 and target[0] in {'A'..'Z', 'a'..'z', '_'} and
     '*' notin target and '&' notin target and ' ' notin target:
    return ("to" & target, "#." & name & "(@)")
  result = (name, "#." & name & "(@)")


proc toClass*(conv :var Converter; cursor :CXCursor; name :string; defaultPublic :bool = false) :cint=
  if name.len == 0 or ' ' in name: return CXChildVisit_Continue.cint
  # Already emitted as a full definition (methods/fields/bases): re-processing a
  # later redeclaration would emit its methods a second time. A field-less but
  # method-bearing class has no fields, so the fields check below can't catch
  # this; track full emissions explicitly.
  if name in conv.seenFullStructs:
    return CXChildVisit_Continue.cint
  let savedModule = conv.module
  if name in conv.seenStructs:
    # Check if existing is a forward declaration — if so, continue to replace it
    let (existingTypeId, originalModule) = conv.seenStructs[name]
    let existingType = conv.ast.data.types.get[existingTypeId]
    if existingType.kind == astTF.tObject and existingType.`object`.fields.isSome:
      return CXChildVisit_Continue.cint
    # The existing node is rendered under the module that first declared it, so
    # build its replacement under that module too: every addSrc below stores
    # text in `conv.module`'s source, and the resulting Locations are resolved
    # against that same module at codegen time. Building under a different
    # module would point this node's Locations at the wrong source string and
    # render as garbage. Restored before methods are emitted (see below).
    conv.module = originalModule
  let commentOpt = conv.add_comment(cursor)
  let className = conv.addName(name)
  # Collect public fields
  var ctx = ChildCtx(conv: addr conv, name: if defaultPublic: "public" else: "")
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
      let fieldTypeExpr = ctx.conv[].ast.add_expression_type(fieldTypeId)
      let bindingId   = ctx.conv[].ast.add_binding(Binding(name: some(fieldName), dataType: some(fieldTypeExpr)))
      ctx.ids.add bindingId
    return CXChildVisit_Continue.cint
  , addr ctx)
  var firstField :Option[astTF.Id]= none(astTF.Id)
  if ctx.ids.len > 0:
    for idx in 0..<ctx.ids.len - 1:
      conv.ast.data.bindings.get[ctx.ids[idx]].next = some(ctx.ids[idx + 1])
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
    conv.ast.data.pragmas.get[inheritableId].next = some(pragmaId)
    finalPragma = inheritableId
  let replacementType = Type(kind: astTF.tObject, `object`: TypeObject(name: some(className), fields: firstField, pragmas: some(finalPragma), link: linkRange))
  var typeId :astTF.Id
  if name in conv.seenStructs:
    let (existingTypeId, _) = conv.seenStructs[name]
    conv.ast.data.types.get[existingTypeId] = replacementType
    typeId = existingTypeId
  else:
    typeId = conv.ast.add_type(replacementType)
    conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: typeId, comment: commentOpt)))
  conv.seenStructs[name] = (typeId, conv.module)
  if not isForward: conv.seenFullStructs.incl name
  conv.module = savedModule
  # Now emit methods, constructors, destructors
  discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
    let conv = cast[ptr Converter](data)
    let childKind = clang_getCursorKind(child)
    case childKind
    of CXCursor_Constructor        : discard conv[].toConstructor(child, child.spelling)
    of CXCursor_Destructor         : discard conv[].toDestructor(child, child.spelling)
    of CXCursor_CXXMethod          : discard conv[].toMethod(child, child.spelling)
    of CXCursor_ConversionFunction : discard conv[].toMethod(child, child.spelling)
    of CXCursor_StructDecl         : discard conv[].toClass(child, child.spelling, defaultPublic = true)
    of CXCursor_ClassDecl          : discard conv[].toClass(child, child.spelling)
    of CXCursor_EnumDecl           : discard conv[].toEnum(child, child.spelling)
    else                           : discard
    return CXChildVisit_Continue.cint
  , addr conv)
  return CXChildVisit_Continue.cint


proc toMethod*(conv :var Converter; cursor :CXCursor; name :string) :cint=
  if name in AllocationOperators:
    conv.emitSkipNote("Skipped " & name & "  (" & cursor.sourceLocation & ")")
    return CXChildVisit_Continue.cint
  if conv.signatureUsesSimdRegister(cursor):
    return conv.skipSimdRegister(cursor, name)
  let isStatic   = clang_CXXMethod_isStatic(cursor) != 0
  let isOperator = name.startsWith("operator")
  let funcType   = clang_getCursorType(cursor)
  let retType    = clang_getResultType(funcType)
  let retOpt     = if retType.kind == CXType_Void: none(astTF.Id) else: some(conv.ast.add_expression_type(conv.convertType(retType)))
  # Build arguments
  let argc   = clang_Cursor_getNumArguments(cursor)
  var argIds :seq[astTF.Id]= @[]
  if not isStatic:
    let isConst      = clang_CXXMethod_isConst(cursor) != 0
    let parentCursor = clang_getCursorSemanticParent(cursor)
    let parentTypeId   = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName(parentCursor.spelling), mutable: some(not isConst))))
    let parentTypeExpr = conv.ast.add_expression_type(parentTypeId)
    let thisBinding  = conv.ast.add_binding(Binding(name: some(conv.addName("this")), dataType: some(parentTypeExpr), private: some(true)))
    argIds.add thisBinding
  else:
    let parentCursor = clang_getCursorSemanticParent(cursor)
    let parentExpr   = conv.ast.add_expression(Expression(kind: astTF.eIdentifier, identifier: ExpressionIdentifier(name: conv.addName(parentCursor.spelling))))
    let typedescId   = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName("typedesc"), instantiation: some(parentExpr))))
    let typedescExpr = conv.ast.add_expression_type(typedescId)
    let selfBinding  = conv.ast.add_binding(Binding(name: some(conv.addName("_")), dataType: some(typedescExpr), private: some(true)))
    argIds.add selfBinding
  for idx in 0..<argc:
    let arg       = clang_Cursor_getArgument(cursor, idx.cuint)
    let argName   = if arg.spelling.len > 0: arg.spelling else: "a" & $idx
    let argIdent  = conv.addRenamed(Parameter, argName)
    let argTypeId = conv.convertType(clang_getCursorType(arg))
    let argTypeExpr = conv.ast.add_expression_type(argTypeId)
    let bindingId = conv.ast.add_binding(Binding(name: some(argIdent), dataType: some(argTypeExpr), private: some(true)))
    argIds.add bindingId
  var firstArg :Option[astTF.Id]= none(astTF.Id)
  if argIds.len > 0:
    for idx in 0..<argIds.len - 1:
      conv.ast.data.bindings.get[argIds[idx]].next = some(argIds[idx + 1])
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
    impure     : some(true),
    pragmas    : some(pragmaId)))
  conv.add_statement_chained(Statement(kind: astTF.sProcedure, procedure: StatementProcedure(id: procId)))
  return CXChildVisit_Continue.cint


proc toConstructor*(conv :var Converter; cursor :CXCursor; name :string) :cint=
  if conv.signatureUsesSimdRegister(cursor):
    return conv.skipSimdRegister(cursor, name)
  let parentCursor = clang_getCursorSemanticParent(cursor)
  let parentName   = parentCursor.spelling
  let retTypeId    = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName(parentName))))
  let retTypeExpr  = conv.ast.add_expression_type(retTypeId)
  let argc = clang_Cursor_getNumArguments(cursor)
  var argIds :seq[astTF.Id]= @[]
  for idx in 0..<argc:
    let arg       = clang_Cursor_getArgument(cursor, idx.cuint)
    let argName   = if arg.spelling.len > 0: arg.spelling else: "a" & $idx
    let argIdent  = conv.addRenamed(Parameter, argName)
    let argTypeId = conv.convertType(clang_getCursorType(arg))
    let argTypeExpr = conv.ast.add_expression_type(argTypeId)
    let bindingId = conv.ast.add_binding(Binding(name: some(argIdent), dataType: some(argTypeExpr), private: some(true)))
    argIds.add bindingId
  var firstArg :Option[astTF.Id]= none(astTF.Id)
  if argIds.len > 0:
    for idx in 0..<argIds.len - 1:
      conv.ast.data.bindings.get[argIds[idx]].next = some(argIds[idx + 1])
    firstArg = some(argIds[0])
  let pragmaId = conv.constructorPragmas(cursor)
  let procName = conv.addRenamed(Proc, conv.constructorName(parentName))
  let procId   = conv.ast.add_procedure(Procedure(
    name       : some(procName),
    arguments  : firstArg,
    returnType : some(retTypeExpr),
    impure     : some(true),
    pragmas    : some(pragmaId)))
  conv.add_statement_chained(Statement(kind: astTF.sProcedure, procedure: StatementProcedure(id: procId)))
  return CXChildVisit_Continue.cint


proc toDestructor*(conv :var Converter; cursor :CXCursor; name :string) :cint=
  let parentCursor = clang_getCursorSemanticParent(cursor)
  let parentName   = parentCursor.spelling
  let parentTypeId   = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName(parentName), mutable: some(true))))
  let parentTypeExpr = conv.ast.add_expression_type(parentTypeId)
  let thisBinding  = conv.ast.add_binding(Binding(name: some(conv.addName("this")), dataType: some(parentTypeExpr), private: some(true)))
  let pragmaId     = conv.destructorPragmas(cursor)
  let procName     = conv.addRenamed(Proc, conv.destructorName(parentName))
  let procId       = conv.ast.add_procedure(Procedure(
    name      : some(procName),
    arguments : some(thisBinding),
    impure    : some(true),
    pragmas   : some(pragmaId)))
  conv.add_statement_chained(Statement(kind: astTF.sProcedure, procedure: StatementProcedure(id: procId)))
  return CXChildVisit_Continue.cint


proc buildClassTemplate(conv :var Converter; cursor :CXCursor; name :string; isForward :bool) :Type =
  let className = conv.addName(name)
  # Collect template type parameters
  var templateCtx = ChildCtx(conv: addr conv)
  discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
    if clang_getCursorKind(child) == CXCursor_TemplateTypeParameter:
      let ctx       = cast[ptr ChildCtx](data)
      let paramName = ctx.conv[].addName(child.spelling)
      let bindingId = ctx.conv[].ast.add_binding(Binding(name: some(paramName), private: some(true)))
      ctx.ids.add bindingId
    return CXChildVisit_Continue.cint
  , addr templateCtx)
  var firstGeneric :Option[astTF.Id]= none(astTF.Id)
  if templateCtx.ids.len > 0:
    for idx in 0..<templateCtx.ids.len - 1:
      conv.ast.data.bindings.get[templateCtx.ids[idx]].next = some(templateCtx.ids[idx + 1])
    firstGeneric = some(templateCtx.ids[0])
  # Collect fields
  var firstField :Option[astTF.Id]= none(astTF.Id)
  if not isForward:
    var fieldCtx = ChildCtx(conv: addr conv)
    discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
      if clang_getCursorKind(child) == CXCursor_FieldDecl:
        let ctx         = cast[ptr ChildCtx](data)
        let fieldName   = ctx.conv[].addRenamed(Field, child.spelling)
        let fieldTypeId = ctx.conv[].convertType(clang_getCursorType(child))
        let fieldTypeExpr = ctx.conv[].ast.add_expression_type(fieldTypeId)
        let bindingId   = ctx.conv[].ast.add_binding(Binding(name: some(fieldName), dataType: some(fieldTypeExpr)))
        ctx.ids.add bindingId
      return CXChildVisit_Continue.cint
    , addr fieldCtx)
    if fieldCtx.ids.len > 0:
      for idx in 0..<fieldCtx.ids.len - 1:
        conv.ast.data.bindings.get[fieldCtx.ids[idx]].next = some(fieldCtx.ids[idx + 1])
      firstField = some(fieldCtx.ids[0])
  let pragmaId = conv.classPragmas(cursor, isForward)
  result = Type(kind: astTF.tObject, `object`: TypeObject(name: some(className), fields: firstField, generics: firstGeneric, pragmas: some(pragmaId)))


proc hasFields(conv :var Converter; cursor :CXCursor) :bool =
  var found = false
  discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
    if clang_getCursorKind(child) == CXCursor_FieldDecl:
      cast[ptr bool](data)[] = true
    return CXChildVisit_Continue.cint
  , addr found)
  result = found


proc toClassTemplate*(conv :var Converter; cursor :CXCursor; name :string) :cint=
  if name.len == 0 or ' ' in name: return CXChildVisit_Continue.cint

  let isForward = not conv.hasFields(cursor)

  if name in conv.seenStructs:
    if isForward:
      return CXChildVisit_Continue.cint
    let (existingTypeId, originalModule) = conv.seenStructs[name]
    let savedModule = conv.module
    conv.module = originalModule
    let replacementType = conv.buildClassTemplate(cursor, name, false)
    conv.ast.data.types.get[existingTypeId] = replacementType
    conv.module = savedModule
    return CXChildVisit_Continue.cint

  let objectType = conv.buildClassTemplate(cursor, name, isForward)
  let typeId = conv.ast.add_type(objectType)
  conv.add_statement_chained(Statement(kind: astTF.sType, `type`: StatementType(id: typeId)))
  conv.seenStructs[name] = (typeId, conv.module)
  return CXChildVisit_Continue.cint


proc identifierTokens(text :string) :seq[string]=
  var token = ""
  for character in text:
    if character in IdentChars:
      token.add character
    elif token.len > 0:
      result.add token
      token = ""
  if token.len > 0:
    result.add token


proc collectChildren(cursor :CXCursor) :seq[CXCursor]=
  var children :seq[CXCursor]= @[]
  discard clang_visitChildren(cursor, proc(child :CXCursor; parent :CXCursor; data :pointer) :cint {.cdecl.}=
    cast[ptr seq[CXCursor]](data)[].add child
    return CXChildVisit_Continue.cint
  , addr children)
  result = children


proc packTypeNames(children :seq[CXCursor]) :seq[string]=
  # A parameter pack (`Values... values`) shows up as a ParmDecl whose type spelling
  # ends in `...`. Collect the type identifiers it mentions so the matching template
  # type parameter can be dropped from the generics.
  for child in children:
    if clang_getCursorKind(child) == CXCursor_ParmDecl and "..." in clang_getCursorType(child).typeSpelling:
      for token in identifierTokens(clang_getCursorType(child).typeSpelling):
        if token notin result: result.add token


proc toFunctionTemplate*(conv :var Converter; cursor :CXCursor; name :string) :cint=
  # C++ parameter packs have no Nim type equivalent, so we model them like C
  # variadics: emit the fixed parameters, drop the pack parameter and its template
  # type parameter, and append `{.varargs.}` so the call site forwards the rest for
  # the C++ compiler to deduce.
  let children  = collectChildren(cursor)
  let packTypes = packTypeNames(children)
  let hasPack   = packTypes.len > 0
  let funcName  = conv.addRenamed(Proc, name)
  let qualified = cursor.qualifiedName
  let funcType  = clang_getCursorType(cursor)
  let retType   = clang_getResultType(funcType)
  let retOpt    = if retType.kind == CXType_Void: none(astTF.Id) else: some(conv.ast.add_expression_type(conv.convertType(retType)))
  # Collect template type parameters, skipping the pack's own type parameter.
  var genericIds :seq[astTF.Id]= @[]
  for child in children:
    if clang_getCursorKind(child) == CXCursor_TemplateTypeParameter and child.spelling notin packTypes:
      let paramName = conv.addName(child.spelling)
      genericIds.add conv.ast.add_binding(Binding(name: some(paramName), private: some(true)))
  var firstGeneric :Option[astTF.Id]= none(astTF.Id)
  if genericIds.len > 0:
    for idx in 0..<genericIds.len - 1:
      conv.ast.data.bindings.get[genericIds[idx]].next = some(genericIds[idx + 1])
    firstGeneric = some(genericIds[0])

  var argIds :seq[astTF.Id]= @[]
  for child in children:
    if clang_getCursorKind(child) == CXCursor_ParmDecl and not clang_getCursorType(child).typeSpelling.contains("..."):
      let argName   = if child.spelling.len > 0: child.spelling else: "a" & $argIds.len
      let argIdent  = conv.addRenamed(Parameter, argName)
      let argTypeId = conv.convertType(clang_getCursorType(child))
      let argTypeExpr = conv.ast.add_expression_type(argTypeId)
      argIds.add conv.ast.add_binding(Binding(name: some(argIdent), dataType: some(argTypeExpr), private: some(true)))
  var firstArg :Option[astTF.Id]= none(astTF.Id)
  if argIds.len > 0:
    for idx in 0..<argIds.len - 1:
      conv.ast.data.bindings.get[argIds[idx]].next = some(argIds[idx + 1])
    firstArg = some(argIds[0])

  let importExpr = if hasPack: qualified & "(@)" else: qualified & "<'*0>(@)"
  var pragmaPairs :seq[(system.string, system.string)]= @[]
  if hasPack: pragmaPairs.add ("varargs", "")
  pragmaPairs.add ("importcpp", importExpr)
  pragmaPairs.add conv.linkPragma
  let pragmaId = conv.chainPragmas(pragmaPairs)
  let procId = conv.ast.add_procedure(Procedure(
    name       : some(funcName),
    generics   : firstGeneric,
    arguments  : firstArg,
    returnType : retOpt,
    impure     : some(true),
    pragmas    : some(pragmaId)))
  conv.add_statement_chained(Statement(kind: astTF.sProcedure, procedure: StatementProcedure(id: procId)))
  return CXChildVisit_Continue.cint

proc generateFunctionPointerHelper*(conv :var Converter, procTypeId: astTF.Id) =
  let procedureId = conv.ast.typ(procTypeId).procedure.id
  let nameLocation = conv.ast.procedure(procedureId).name.get.location
  let renamedAlias = conv.ast.source(conv.module, nameLocation, false)

  let helperName      = conv.addName("to" & renamedAlias)
  let valueIdent      = conv.addName("value")
  let pointerTypeId   = conv.add_primitive("pointer")
  let pointerTypeExpr = conv.ast.add_expression_type(pointerTypeId)
  let valueBinding    = conv.ast.add_binding(Binding(name: some(valueIdent), dataType: some(pointerTypeExpr), private: some(true)))

  let returnTypeId    = conv.add_primitive(renamedAlias)
  let returnTypeExpr  = conv.ast.add_expression_type(returnTypeId)

  let inlinePragma    = conv.addPragma("inline")

  let castLoc         = conv.addSrc("cast")
  let castName        = conv.ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.generic, value: castLoc)))
  let genericTypeId   = conv.add_primitive(renamedAlias)
  let genericTypeExpr = conv.ast.add_expression_type(genericTypeId)
  let genericBinding  = conv.ast.add_binding(Binding(dataType: some(genericTypeExpr)))
  let valueExprId     = conv.ast.add_expression(Expression(kind: astTF.eIdentifier, identifier: ExpressionIdentifier(name: valueIdent)))
  let argBinding      = conv.ast.add_binding(Binding(value: some(valueExprId)))
  let castCallId      = conv.ast.add_expression(Expression(kind: astTF.eCall, call: ExpressionCall(name: castName, generics: some(genericBinding), arguments: some(argBinding))))

  let depthId         = conv.ast.add_depth(Depth(indent: some(1'u64)))
  let bodyStmtId      = conv.ast.add_statement(Statement(kind: astTF.sExpression, expression: StatementExpression(id: castCallId, depth: some(depthId))))

  let helperProcId = conv.ast.add_procedure(Procedure(
    name       : some(helperName),
    arguments  : some(valueBinding),
    returnType : some(returnTypeExpr),
    impure     : some(true),
    pragmas    : some(inlinePragma),
    body       : some(bodyStmtId),
  ))
  conv.add_statement_chained(Statement(kind: astTF.sProcedure, procedure: StatementProcedure(id: helperProcId)))

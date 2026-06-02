# @deps std
from std/strutils import startsWith, replace, contains, split, strip, find, rfind
from std/os import isRelativeTo
# @deps nonim
import nonim/ast as astTF
# @deps henka
import ./[common, clang, pragmas]


proc convert_type*(conv: var Converter, typ: CXType): astTF.Id

const clang_RecordKinds = {CXCursor_StructDecl, CXCursor_ClassDecl, CXCursor_UnionDecl, CXCursor_ClassTemplate}


proc stripNamespace*(name: string): string =
  let bracket = name.find({'<', '['})
  let scanEnd = if bracket >= 0: bracket - 1 else: name.high
  let marker  = name.rfind("::", last = scanEnd)
  result = if marker >= 0: name[marker + 2 .. ^1] else: name


proc isMemberTypedef(typ: CXType): bool =
  let decl = clang_getTypeDeclaration(typ)
  if clang_getCursorKind(decl) notin {CXCursor_TypedefDecl, CXCursor_TypeAliasDecl}:
    return false
  result = clang_getCursorKind(clang_getCursorSemanticParent(decl)) in clang_RecordKinds


const clang_Primitives = {
  CXType_Bool, CXType_Void,
  CXType_SChar, CXType_Char16, CXType_Char32, CXType_Short, CXType_Int, CXType_Long, CXType_LongLong,
  CXType_UChar, CXType_UShort, CXType_UInt, CXType_ULong, CXType_ULongLong,
  CXType_WChar, CXType_Char_S,
  CXType_Float, CXType_Double, CXType_LongDouble
}


proc splitTemplateArgs(argsStr: string): seq[string] =
  var depth = 0
  var current = ""
  for character in argsStr:
    if character == '<': depth += 1
    elif character == '>': depth -= 1
    if character == ',' and depth == 0:
      result.add current.strip
      current = ""
    else:
      current.add character
  if current.strip.len > 0:
    result.add current.strip

proc add_primitive*(conv: var Converter, rawName: string): astTF.Id =
  let name = stripNamespace(rawName)
  let angleBracket = name.find('<')
  if angleBracket < 0:
    return conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(name: conv.addName(name))))

  let baseName = name[0..<angleBracket]
  let closingBracket = name.rfind('>')
  let argsStr = name[angleBracket + 1 ..< closingBracket]
  let args = splitTemplateArgs(argsStr)

  var firstExpr = none(astTF.Id)
  var prevExpr = none(astTF.Id)
  for arg in args:
    let nimArg = stripNamespace(arg).replace("<", "[").replace(">", "]")
    let exprId = conv.ast.add_expression(Expression(kind: astTF.eIdentifier, identifier: ExpressionIdentifier(
      name: conv.addName(nimArg))))
    if prevExpr.isSome:
      conv.ast.data.expressions.get[prevExpr.get].identifier.next = some(exprId)
    if firstExpr.isNone: firstExpr = some(exprId)
    prevExpr = some(exprId)

  result = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(
    name: conv.addName(baseName),
    instantiation: firstExpr)))


proc toUnsupported*(conv: var Converter, typ: CXType): astTF.Id =
  result = conv.add_primitive("UNSUPPORTED_" & $typ.kind)


proc toPrimitive*(conv: var Converter, typ: CXType): astTF.Id =
  result = conv.add_primitive(case typ.kind
    of CXType_Bool      : "bool"
    of CXType_Void      : "void"
    of CXType_SChar     : "cschar"
    of CXType_Char16    : "uint16"
    of CXType_Char32    : "uint32"
    of CXType_Short     : "cshort"
    of CXType_Int       : "cint"
    of CXType_Long      : "clong"
    of CXType_LongLong  : "clonglong"
    of CXType_UChar     : "uint8"
    of CXType_UShort    : "cushort"
    of CXType_UInt      : "cuint"
    of CXType_ULong     : "culong"
    of CXType_ULongLong : "culonglong"
    of CXType_WChar     : "cuint"
    of CXType_Char_S    : "cchar"
    of CXType_Float     : "cfloat"
    of CXType_Double     : "cdouble"
    of CXType_LongDouble : "clongdouble"
    else                : "UNKNOWN"
  )


# FIX: Give this proc a proper name
proc toPrimitive2*(conv: var Converter, typ: CXType): astTF.Id =
  var named = typ.typeSpelling
  if named.startsWith("const "):
    named = named[6..^1]

  let mapped = conv.typeMapper(named)
  if mapped.isSome:
    return conv.add_primitive(mapped.get)

  let renamed = conv.sanitizer(conv.renamer(Typedef, named))
  result = conv.add_primitive(renamed)


proc toPointer*(conv: var Converter, typ: CXType): astTF.Id =
  let pointee = clang_getPointeeType(typ)
  if pointee.kind == CXType_FunctionProto:
    return conv.convert_type(pointee)

  if pointee.kind == CXType_Void:
    return conv.add_primitive("pointer")

  if clang_getCanonicalType(pointee).kind == CXType_Void:
    return conv.add_primitive("pointer")

  if pointee.kind == CXType_Char_S:
    return conv.add_primitive("cstring")

  let targetId = conv.convertType(pointee)
  result = conv.ast.add_type(Type(kind: astTF.tPtr, `ptr`: TypePtr(target: targetId)))


proc taggedOrBare(isCpp: bool, taggedKind: LabelKind): LabelKind =
  if isCpp: Typedef else: taggedKind


proc toObject*(conv: var Converter, typ: CXType): astTF.Id =
  var named = typ.typeSpelling
  if named.startsWith("const "):
    named = named[6..^1]

  let mapped = conv.typeMapper(named)
  if mapped.isSome:
    return conv.add_primitive(mapped.get)

  if named.startsWith("struct "):
    let kind = taggedOrBare(conv.isCpp, StructType)
    named = conv.sanitizer(conv.renamer(kind, named[7..^1]))
  elif named.startsWith("union "):
    let kind = taggedOrBare(conv.isCpp, UnionType)
    named = conv.sanitizer(conv.renamer(kind, named[6..^1]))
  elif named.startsWith("enum "):
    named = conv.sanitizer(conv.renamer(Typedef, named[5..^1]))
  elif '<' in named:
    let numArgs = clang_Type_getNumTemplateArguments(typ)
    if numArgs > 0:
      let baseName = stripNamespace(named[0 ..< named.find('<')])
      var firstExpr = none(astTF.Id)
      var prevExpr = none(astTF.Id)
      for argIdx in 0 ..< numArgs:
        let argType = clang_Type_getTemplateArgumentAsType(typ, argIdx.cuint)
        let argTypeId = conv.convertType(argType)
        let exprId = conv.ast.add_expression_type(argTypeId)
        if prevExpr.isSome:
          conv.ast.data.expressions.get[prevExpr.get].`type`.next = some(exprId)
        if firstExpr.isNone: firstExpr = some(exprId)
        prevExpr = some(exprId)
      return conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(
        name: conv.addName(baseName),
        instantiation: firstExpr)))
    return conv.add_primitive(named)
  elif ' ' in named:
    return conv.add_primitive("pointer")
  else:
    named = conv.sanitizer(conv.renamer(Typedef, named))

  result = conv.add_primitive(named)


proc toProcedurePrototype*(
    conv: var Converter,
    typ: CXType,
    pragmaId :Option[astTF.Id]= none(astTF.Id),
    name: string = ""
  ): astTF.Id =
  let retType = clang_getResultType(typ)
  let retOpt  = if retType.kind == CXType_Void: none(astTF.Id) else: some(conv.ast.add_expression_type(conv.convertType(retType)))
  let argc    = clang_getNumArgTypes(typ)
  var argIds: seq[astTF.Id] = @[]

  for idx in 0..<argc:
    let argType   = clang_getArgType(typ, idx.cuint)
    let argTypeId = conv.convertType(argType)
    let argName   = conv.addName("a" & $idx)
    let argTypeExpr = conv.ast.add_expression_type(argTypeId)
    let bindingId = conv.ast.add_binding(Binding(name: some(argName), dataType: some(argTypeExpr), private: some(true)))
    argIds.add bindingId

  let firstArg = conv.linkBindingChain(argIds)

  let procName =
    if name.len > 0: some(conv.addRenamed(Typedef, name))
    else:            none(astTF.Identifier)

  let cdeclPragma = conv.addPragma("cdecl")
  let procId   = conv.ast.add_procedure(Procedure(
    name       : procName,
    arguments  : firstArg,
    returnType : retOpt,
    impure     : some(true),
    pragmas    : some(cdeclPragma)
  ))

  result = conv.ast.add_type(Type(kind: astTF.tProcedure, procedure: TypeProcedure(id: procId, pragmas: pragmaId)))


proc toArray*(conv: var Converter, typ: CXType): astTF.Id =
  let elemType  = clang_getArrayElementType(typ)
  let elemId    = conv.convertType(elemType)
  let count     = clang_getNumElements(typ)
  let countLoc  = conv.addSrc($count)
  let countExpr = conv.ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.integer, value: countLoc)))
  result = conv.ast.add_type(Type(kind: astTF.tArray, array: TypeArray(element: elemId, length: some(countExpr))))


proc typeContainsVector*(typ: CXType, depth: int = 0): bool


type VectorScanCtx = object
  found: bool
  depth: int


proc recordContainsVector(record: CXType, depth: int): bool =
  let decl = clang_getTypeDeclaration(record)
  var ctx = VectorScanCtx(depth: depth)
  discard clang_visitChildren(decl, proc(child: CXCursor; parent: CXCursor; data: pointer): cint {.cdecl.} =
    let ctx = cast[ptr VectorScanCtx](data)
    if clang_getCursorKind(child) == CXCursor_FieldDecl and typeContainsVector(clang_getCursorType(child), ctx.depth + 1):
      ctx.found = true
    return CXChildVisit_Continue.cint
  , addr ctx)
  result = ctx.found


proc typeContainsVector*(typ: CXType, depth: int = 0): bool =
  if depth > 8: return false
  let canonical = clang_getCanonicalType(typ)
  result = case canonical.kind
    of CXType_Vector                                                  : true
    of CXType_ConstantArray, CXType_IncompleteArray                   : typeContainsVector(clang_getArrayElementType(canonical), depth + 1)
    of CXType_Pointer, CXType_LValueReference, CXType_RValueReference : typeContainsVector(clang_getPointeeType(canonical), depth + 1)
    of CXType_Record                                                  : recordContainsVector(canonical, depth)
    else                                                              : false


proc registerDecl(typ: CXType): CXCursor =
  var canonical = clang_getCanonicalType(typ)
  var guard = 0
  while guard < 8:
    inc guard
    case canonical.kind
    of CXType_LValueReference, CXType_RValueReference, CXType_Pointer:
      canonical = clang_getCanonicalType(clang_getPointeeType(canonical))
    of CXType_ConstantArray, CXType_IncompleteArray:
      canonical = clang_getCanonicalType(clang_getArrayElementType(canonical))
    else:
      break
  result = clang_getTypeDeclaration(canonical)


proc declaredExternally(conv: Converter, typ: CXType): bool =
  let decl = registerDecl(typ)
  if clang_Location_isInSystemHeader(clang_getCursorLocation(decl)) != 0:
    return true
  if conv.rootDir.len == 0: return false
  let file = decl.cursorFileName
  if file.len == 0: return false
  result = not file.isRelativeTo(conv.rootDir)


proc usesSimdRegister*(conv: Converter, typ: CXType): bool =
  var value = typ
  if value.kind in {CXType_LValueReference, CXType_RValueReference}:
    value = clang_getPointeeType(value)
  if clang_getCanonicalType(value).kind == CXType_Vector:
    return true
  if not typeContainsVector(value):
    return false

  result = conv.declaredExternally(value)


proc toReference*(conv: var Converter, typ: CXType): astTF.Id =
  let pointee = clang_getPointeeType(typ)
  let isConst = pointee.typeSpelling.startsWith("const ")
  let targetId = conv.convert_type(pointee)
  if isConst:
    result = targetId
  elif typ.kind == CXType_LValueReference:
    var target = conv.ast.data.types.get[targetId]
    case target.kind
    of astTF.tPrimitive : target.primitive.mutable = some(true)
    of astTF.tPtr       : target.`ptr`.mutable     = some(true)
    of astTF.tArray     : target.array.mutable     = some(true)
    of astTF.tObject    : target.`object`.mutable  = some(true)
    else                : discard
    conv.ast.data.types.get[targetId] = target
    result = targetId
  elif typ.kind == CXType_RValueReference:
    # TODO: handle non-primitive targets on `T&&` → `sink T` case.
    let target = conv.ast.data.types.get[targetId]
    if target.kind == astTF.tPrimitive:
      result = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(
        name: target.primitive.name,
        keyword: some(conv.addName("sink"))
      )))
    else:
      result = targetId
  else:
    result = targetId


proc convert_type*(conv: var Converter, typ: CXType): astTF.Id =
  if isMemberTypedef(typ):
    return conv.convert_type(clang_getCanonicalType(typ))

  result = case typ.kind
    of clang_Primitives       : conv.toPrimitive(typ)
    of CXType_Typedef         : conv.toPrimitive2(typ)
    of CXType_Unexposed       : conv.toPrimitive2(typ)
    of CXType_Pointer         : conv.toPointer(typ)
    of CXType_MemberPointer   : conv.add_primitive("pointer")
    of CXType_Elaborated      : conv.toObject(typ)
    of CXType_Record          : conv.toObject(typ)
    of CXType_FunctionProto   : conv.toProcedurePrototype(typ)
    of CXType_FunctionNoProto : conv.toProcedurePrototype(typ)
    of CXType_LValueReference : conv.toReference(typ)
    of CXType_RValueReference : conv.toReference(typ)
    of CXType_ConstantArray   : conv.toArray(typ)
    of CXType_IncompleteArray :
      let elemType = clang_getArrayElementType(typ)
      let elemId = conv.convert_type(elemType)
      let arrayName = conv.addName("UncheckedArray")
      conv.ast.add_type(Type(kind: astTF.tArray, array: TypeArray(name: some(arrayName), element: elemId)))
    of CXType_Auto            : conv.add_primitive("auto")
    else                      : conv.toUnsupported(typ)

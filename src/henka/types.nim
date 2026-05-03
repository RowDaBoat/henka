# @deps std
from std/strutils import startsWith, replace, contains, split, strip, find, rfind
# @deps slate
import slate/ast as astTF
# @deps henka
import ./[common, clang, pragmas]


proc convert_type*(conv: var Converter, typ: CXType): astTF.Id

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

proc add_primitive*(conv: var Converter, name: string): astTF.Id =
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
    let nimArg = arg.replace("<", "[").replace(">", "]")
    let exprId = conv.ast.add_expression(Expression(kind: astTF.eIdentifier, identifier: ExpressionIdentifier(
      name: conv.addName(nimArg))))
    if prevExpr.isSome:
      conv.ast.data.expressions[prevExpr.get].identifier.next = some(exprId)
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

  result = conv.add_primitive(named)


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


proc toObject*(conv: var Converter, typ: CXType): astTF.Id =
  var named = typ.typeSpelling
  if named.startsWith("const "):
    named = named[6..^1]

  let mapped = conv.typeMapper(named)
  if mapped.isSome:
    return conv.add_primitive(mapped.get)

  if named.startsWith("struct "):
    named = conv.sanitizer(conv.renamer(StructType, named[7..^1]))
  elif named.startsWith("union "):
    named = conv.sanitizer(conv.renamer(UnionType, named[6..^1]))
  elif named.startsWith("enum "):
    named = conv.sanitizer(conv.renamer(Typedef, named[5..^1]))
  elif '<' in named:
    let numArgs = clang_Type_getNumTemplateArguments(typ)
    if numArgs > 0:
      let baseName = named[0 ..< named.find('<')]
      var firstExpr = none(astTF.Id)
      var prevExpr = none(astTF.Id)
      for argIdx in 0 ..< numArgs:
        let argType = clang_Type_getTemplateArgumentAsType(typ, argIdx.cuint)
        let argTypeId = conv.convertType(argType)
        let exprId = conv.ast.add_expression_type(argTypeId)
        if prevExpr.isSome:
          conv.ast.data.expressions[prevExpr.get].`type`.next = some(exprId)
        if firstExpr.isNone: firstExpr = some(exprId)
        prevExpr = some(exprId)
      return conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(
        name: conv.addName(baseName),
        instantiation: firstExpr)))
    return conv.add_primitive(named)
  elif ' ' in named:
    return conv.add_primitive("pointer")
  else:
    named = conv.sanitizer(named)

  result = conv.add_primitive(named)


proc toProcedure*(conv: var Converter, typ: CXType): astTF.Id =
  let retType = clang_getResultType(typ)
  let retOpt  = if retType.kind == CXType_Void: none(astTF.Id) else: some(conv.ast.add_expression_type(conv.convertType(retType)))
  let argc    = clang_getNumArgTypes(typ)
  var firstArg: Option[astTF.Id] = none(astTF.Id)
  var argIds: seq[astTF.Id]      = @[]

  for idx in 0..<argc:
    let argType   = clang_getArgType(typ, idx.cuint)
    let argTypeId = conv.convertType(argType)
    let argName   = conv.addName("a" & $idx)
    let argTypeExpr = conv.ast.add_expression_type(argTypeId)
    let bindingId = conv.ast.add_binding(Binding(name: some(argName), dataType: some(argTypeExpr), private: true))
    argIds.add bindingId

  if argIds.len > 0:
    for idx in 0..<argIds.len - 1:
      conv.ast.data.bindings[argIds[idx]].next = some(argIds[idx + 1])
    firstArg = some(argIds[0])

  let cdeclPragma = conv.addPragma("cdecl")
  let procId   = conv.ast.add_procedure(Procedure(
    arguments  : firstArg,
    returnType : retOpt,
    impure     : true,
    private    : true,
    pragmas    : some(cdeclPragma)
  ))

  result = conv.ast.add_type(Type(kind: astTF.tProcedure, procedure: TypeProcedure(id: procId)))


proc toArray*(conv: var Converter, typ: CXType): astTF.Id =
  let elemType  = clang_getArrayElementType(typ)
  let elemId    = conv.convertType(elemType)
  let count     = clang_getNumElements(typ)
  let countLoc  = conv.addSrc($count)
  let countExpr = conv.ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.integer, value: countLoc)))
  result = conv.ast.add_type(Type(kind: astTF.tArray, array: TypeArray(element: elemId, length: some(countExpr))))


proc toReference*(conv: var Converter, typ: CXType): astTF.Id =
  let pointee = clang_getPointeeType(typ)
  let isConst = pointee.typeSpelling.startsWith("const ")
  let targetId = conv.convert_type(pointee)
  if isConst:
    result = targetId
  elif typ.kind == CXType_LValueReference:
    var target = conv.ast.data.types[targetId]
    target.primitive.mutable = true
    conv.ast.data.types[targetId] = target
    result = targetId
  elif typ.kind == CXType_RValueReference:
    result = conv.ast.add_type(Type(kind: astTF.tPrimitive, primitive: TypePrimitive(
      name: conv.ast.data.types[targetId].primitive.name,
      keyword: some(conv.addName("sink")))))
  else:
    result = targetId


proc convert_type*(conv: var Converter, typ: CXType): astTF.Id =
  result = case typ.kind
    of clang_Primitives       : conv.toPrimitive(typ)
    of CXType_Typedef         : conv.toPrimitive2(typ)
    of CXType_Unexposed       : conv.toPrimitive2(typ)
    of CXType_Pointer         : conv.toPointer(typ)
    of CXType_MemberPointer   : conv.add_primitive("pointer")
    of CXType_Elaborated      : conv.toObject(typ)
    of CXType_Record          : conv.toObject(typ)
    of CXType_FunctionProto   : conv.toProcedure(typ)
    of CXType_FunctionNoProto : conv.toProcedure(typ)
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

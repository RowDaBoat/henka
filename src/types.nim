import std/json
import std/[strutils, strformat, sequtils]
import node, error, renamer


proc primitiveToNim(typ: string): string =
  case typ
  of "void": "void"
  of "float": "cfloat"
  of "double": "cdouble"
  of "long double": "clongdouble"
  of "char": "cchar"
  of "signed char": "int8"
  of "unsigned char": "uint8"
  of "short": "cshort"
  of "unsigned short": "cushort"
  of "int": "cint"
  of "unsigned int": "cuint"
  of "long": "clong"
  of "unsigned long": "culong"
  of "long long": "clonglong"
  of "unsigned long long": "culonglong"
  else: typ


proc parseQualType(qualType: string, renamer: Renamer): string


proc parseFunctionPointerQualType(typ: string, renamer: Renamer): string =
  let pointerIndex = typ.find("(*)")
  let returnNimType = parseQualType(typ[0..<pointerIndex], renamer)

  let paramsStart = typ.find('(', pointerIndex + 3) + 1
  let paramsEnd = typ.rfind(')')
  let paramsStr = typ[paramsStart..<paramsEnd].strip()

  let hasParameters = paramsStr.len > 0 and paramsStr != "void"
  var joinedParameters = ""

  if hasParameters:
    let splitParameters = paramsStr.split(", ").pairs.toSeq
    let renamedParameters = splitParameters.mapIt(&"a{it[0]}: {parseQualType(it[1], renamer)}")
    joinedParameters = renamedParameters.join(", ")

  let returnPart = if returnNimType == "void": "" else: &": {returnNimType}"
  &"proc({joinedParameters}){returnPart} " & "{.cdecl.}"


proc parseQualType(qualType: string, renamer: Renamer): string =
  let typ = qualType.strip()

  if typ.startsWith("const "):
    return parseQualType(typ[6..^1], renamer)

  if typ.startsWith("volatile "):
    return parseQualType(typ[9..^1], renamer)

  if typ.startsWith("restrict "):
    return parseQualType(typ[9..^1], renamer)

  if "(*)" in typ:
    return parseFunctionPointerQualType(typ, renamer)

  if typ.endsWith(" *") or (typ.endsWith("*") and typ.len > 1):
    let base = typ[0..^2].strip()

    if base == "char":
      return "cstring"

    if base == "void":
      return "pointer"

    return "ptr " & parseQualType(base, renamer)

  if typ.startsWith("struct "):
    return renamer(StructType, typ[7..^1])

  if typ.startsWith("union "):
    return renamer(UnionType, typ[6..^1])

  if typ.startsWith("enum "):
    return renamer(EnumType, typ[5..^1])

  primitiveToNim(typ)


proc qualTypeToNim*(typeRef: JsonNode, renamer: Renamer): string =
  parseQualType(typeRef.qualType, renamer)


proc returnTypeToNim*(funcTypeRef: JsonNode, renamer: Renamer): string =
  let qualType = funcTypeRef.qualType
  let parenIndex = qualType.find('(')
  let returnQualType = if parenIndex >= 0: qualType[0..<parenIndex] else: qualType
  parseQualType(returnQualType, renamer)


proc builtInType*(typeNode: JsonNode): string =
  primitiveToNim(typeNode.typ.qualType)


proc astTypeToNim*(typeNode: JsonNode): string


proc constantArrayType(typeNode: JsonNode): string =
  let elementType = typeNode.inner[0].astTypeToNim
  return &"array[{typeNode.size}, {elementType}]"


proc isFunctionType(typeNode: JsonNode): bool =
  let kind = typeNode.astKind
  let isTransparentWrapper = kind == "ParenType"
  let isFunctionKind = kind in ["FunctionProtoType", "FunctionNoProtoType"]
  isFunctionKind or (isTransparentWrapper and typeNode.inner[0].isFunctionType)


proc pointerType(typeNode: JsonNode): string =
  let inner = typeNode.inner

  if inner.isNil or inner.kind != JArray or inner.len == 0:
    return "pointer"

  let innerNode = inner[0]

  if innerNode.isFunctionType:
    return innerNode.astTypeToNim

  let baseType = innerNode.astTypeToNim

  case baseType:
  of "cchar": return "cstring"
  of "void": return "pointer"
  else: return &"ptr {baseType}"


proc functionPrototype(typeNode: JsonNode): string =
  let elems = typeNode.inner.getElems
  let returnType = if elems.len > 0: elems[0].astTypeToNim else: "void"

  let parameters =
    toSeq(elems[1..^1].pairs)
      .mapIt(&"a{it[0]}: {it[1].astTypeToNim}")
      .join(", ")

  let returnPart = if returnType == "void": "" else: ": " & returnType
  return &"proc({parameters}){returnPart} " & "{.cdecl.}"


proc astTypeToNim*(typeNode: JsonNode): string =
  let kind = typeNode.astKind

  case kind
  of "ElaboratedType", "AttributedType", "DecayedType", "AdjustedType", "QualType":
    return typeNode.inner[0].astTypeToNim

  of "RecordType", "EnumType", "TypedefType":
    return typeNode.decl.name

  of "BuiltinType":
    return builtInType(typeNode)

  of "ConstantArrayType":
    return constantArrayType(typeNode)

  of "PointerType":
    return pointerType(typeNode)

  of "IncompleteArrayType":
    return "UncheckedArray[" & typeNode.inner[0].astTypeToNim & "]"

  of "ParenType":
    return typeNode.inner[0].astTypeToNim

  of "FunctionProtoType", "FunctionNoProtoType":
    return functionPrototype(typeNode)

  error &"Henka does not support '{kind}' types yet."

import std/json
import std/[strutils, strformat, sequtils]
import node, error


proc primitiveToNim*(typ: string): string =
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


proc parseQualType(qualType: string): string


proc parseFunctionPointerQualType(t: string): string =
  let pointerIndex = t.find("(*)")
  let returnNimType = parseQualType(t[0..<pointerIndex])

  let paramsStart = t.find('(', pointerIndex + 3) + 1
  let paramsEnd = t.rfind(')')
  let paramsStr = t[paramsStart..<paramsEnd].strip()

  let hasParameters = paramsStr.len > 0 and paramsStr != "void"
  let joinedParameters =
    if hasParameters:
      paramsStr.split(", ").pairs.toSeq
        .mapIt(&"a{it[0]}: {parseQualType(it[1])}")
        .join(", ")
    else:
      ""

  let returnPart = if returnNimType == "void": "" else: &": {returnNimType}"
  &"proc({joinedParameters}){returnPart} " & "{.cdecl.}"


proc parseQualType(qualType: string): string =
  let t = qualType.strip()

  if t.startsWith("const "):
    return parseQualType(t[6..^1])

  if t.startsWith("volatile "):
    return parseQualType(t[9..^1])

  if t.startsWith("restrict "):
    return parseQualType(t[9..^1])

  if "(*)" in t:
    return parseFunctionPointerQualType(t)

  if t.startsWith("struct "):
    return t[7..^1]

  if t.startsWith("union "):
    return t[6..^1]

  if t.startsWith("enum "):
    return t[5..^1]

  if t.endsWith(" *") or (t.endsWith("*") and t.len > 1):
    let base = t[0..^2].strip()

    if base == "char":
      return "cstring"

    if base == "void":
      return "pointer"

    return "ptr " & parseQualType(base)

  primitiveToNim(t)


proc qualTypeToNim*(typeRef: JsonNode): string =
  parseQualType(typeRef.qualType)


proc returnTypeToNim*(funcTypeRef: JsonNode): string =
  let qualType = funcTypeRef.qualType
  let parenIndex = qualType.find('(')
  let returnQualType = if parenIndex >= 0: qualType[0..<parenIndex] else: qualType
  parseQualType(returnQualType)


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
  of "ElaboratedType", "AttributedType", "DecayedType", "AdjustedType":
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

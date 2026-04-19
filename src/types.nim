import std/json
import std/[strutils, strformat, sequtils]
import node, error, renamer, pragmas


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
  of "int8_t": "int8"
  of "int16_t": "int16"
  of "int32_t": "int32"
  of "int64_t": "int64"
  of "uint8_t": "uint8"
  of "uint16_t": "uint16"
  of "uint32_t": "uint32"
  of "uint64_t": "uint64"
  of "size_t": "csize_t"
  else: typ


proc parseQualType(qualType: string, renamer: Renamer, unnamed: string = ""): string


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
  &"proc({joinedParameters}){returnPart}" & pragmas(@["cdecl"])


proc parseQualType(qualType: string, renamer: Renamer, unnamed: string = ""): string =
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
    var base = typ[0..^2].strip()
    base.removeSuffix(" const")
    base.removeSuffix("*const")
    base = base.strip()

    if base == "char":
      return "cstring"

    if base == "void":
      return "pointer"

    return "ptr " & parseQualType(base, renamer)

  if typ.endsWith("]"):
    let bracketStart = typ.find('[')
    let baseType = parseQualType(typ[0..<bracketStart], renamer)
    var dimensions: seq[string]
    var rest = typ[bracketStart..^1]
    while rest.len > 0 and rest.startsWith("["):
      let closeIndex = rest.find(']')
      dimensions.add(rest[1..<closeIndex])
      rest = rest[closeIndex + 1..^1]
    result = baseType
    for i in countdown(dimensions.high, 0):
      result = &"array[{dimensions[i]}, {result}]"
    return result

  if typ.startsWith("struct "):
    let name = if unnamed == "": typ[7..^1] else: unnamed
    return renamer(StructType, name)[0]

  if typ.startsWith("union "):
    let name = if unnamed == "": typ[6..^1] else: unnamed
    return renamer(UnionType, name)[0]

  if typ.startsWith("enum "):
    let name = if unnamed == "": typ[5..^1] else: unnamed
    return renamer(EnumType, name)[0]

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


proc astTypeToNim*(typeNode: JsonNode, renamer: Renamer): string


proc constantArrayType(typeNode: JsonNode, renamer: Renamer): string =
  let elementType = typeNode.inner[0].astTypeToNim(renamer)
  return &"array[{typeNode.size}, {elementType}]"


proc isFunctionType(typeNode: JsonNode): bool =
  let kind = typeNode.astKind
  let isTransparentWrapper = kind == "ParenType"
  let isFunctionKind = kind in ["FunctionProtoType", "FunctionNoProtoType"]
  isFunctionKind or (isTransparentWrapper and typeNode.inner[0].isFunctionType)


proc pointerType(typeNode: JsonNode, renamer: Renamer): string =
  let inner = typeNode.inner

  if inner.isNil or inner.kind != JArray or inner.len == 0:
    return "pointer"

  let innerNode = inner[0]

  if innerNode.isFunctionType:
    return innerNode.astTypeToNim(renamer)

  let baseType = innerNode.astTypeToNim(renamer)

  case baseType:
  of "cchar": return "cstring"
  of "void": return "pointer"
  else: return &"ptr {baseType}"


proc functionPrototype(typeNode: JsonNode, renamer: Renamer): string =
  let elems = typeNode.inner.getElems
  let returnType = if elems.len > 0: elems[0].astTypeToNim(renamer) else: "void"

  let parameters =
    toSeq(elems[1..^1].pairs)
      .mapIt(&"a{it[0]}: {it[1].astTypeToNim(renamer)}")
      .join(", ")

  let returnPart = if returnType == "void": "" else: ": " & returnType
  return &"proc({parameters}){returnPart}" & pragmas(@["cdecl"])


proc astTypeToNim*(typeNode: JsonNode, renamer: Renamer): string =
  let kind = typeNode.astKind

  case kind
  of "ElaboratedType":
    let ownedTagDecl = typeNode.ownedTagDecl
    let hasOwnedTagDecl = not ownedTagDecl.isNil and ownedTagDecl.kind == JObject

    if not hasOwnedTagDecl:
      return typeNode.inner[0].astTypeToNim(renamer)

    let qualifier = typeNode.typ.qualType.split(" ")[0]

    let labelKind =
      case qualifier
      of "struct": StructType
      of "union": UnionType
      of "enum": EnumType
      else: StructType

    return renamer(labelKind, ownedTagDecl.resolveName)[0]

  of "AttributedType", "DecayedType", "AdjustedType", "QualType":
    return typeNode.inner[0].astTypeToNim(renamer)

  of "RecordType":
    let declNode = typeNode.decl
    let declName = declNode.resolveName
    let recordKind = if declNode.tag == "union": UnionType else: StructType
    return renamer(recordKind, declName)[0]

  of "EnumType":
    let declNode = typeNode.decl
    let declName = declNode.resolveName
    return renamer(EnumType, declName)[0]

  of "TypedefType":
    let typedefName = typeNode.decl.name
    let primitiveType = primitiveToNim(typedefName)

    let isPrimitive = primitiveType != typedefName
    if isPrimitive:
      return primitiveType

    return renamer(Typedef, typedefName)[0]

  of "BuiltinType":
    return builtInType(typeNode)

  of "ConstantArrayType":
    return constantArrayType(typeNode, renamer)

  of "PointerType":
    let baseType = typeNode.inner[0].astTypeToNim(renamer)

    if baseType == "void":
      return "pointer"

    return "ptr " & baseType

  of "IncompleteArrayType":
    return "UncheckedArray[" & typeNode.inner[0].astTypeToNim(renamer) & "]"

  of "ParenType":
    return typeNode.inner[0].astTypeToNim(renamer)

  of "FunctionProtoType", "FunctionNoProtoType":
    return functionPrototype(typeNode, renamer)

  error &"Henka does not support '{kind}' types yet."

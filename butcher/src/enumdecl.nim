import std/[json, strutils, strformat, sequtils, sets]
import node, renamer, pragmas


proc isEnumConstantDeclaration(node: JsonNode): bool =
  node.astKind == "EnumConstantDecl"


proc explicitValue(constant: JsonNode): string =
  let inner = constant.inner
  let hasExplicitInitializer = not inner.isNil and inner.kind == JArray and inner.len > 0

  if not hasExplicitInitializer:
    return ""

  let expr = inner[0]
  let isConstantExpr = expr.astKind == "ConstantExpr"

  if not isConstantExpr:
    return ""

  expr.getOrDefault("value").getStr


proc enumConstant(constant: JsonNode, renamer: Renamer): string =
  let value = explicitValue(constant)
  let hasValue = value.len > 0
  let (renamed, userPragmas) = renamer(EnumValue, constant.name)
  let pragmas = pragmas(userPragmas)
  if hasValue: &"    {renamed}{pragmas} = {value}"
  else: &"    {renamed}{pragmas}"


proc deduplicateConstants(constants: seq[JsonNode]): tuple[unique: seq[JsonNode], duplicates: seq[JsonNode]] =
  var seenValues: HashSet[string]
  var nextImplicitValue = 0

  for constant in constants:
    let value = explicitValue(constant)
    let isExplicit = value.len > 0
    let resolvedValue = if isExplicit: value else: $nextImplicitValue
    let isDuplicate = resolvedValue in seenValues

    if isDuplicate:
      result.duplicates.add(constant)
    else:
      result.unique.add(constant)
      seenValues.incl(resolvedValue)

    nextImplicitValue = parseInt(resolvedValue) + 1


proc enumPragmas(header: string, name: string, renamed: string): seq[string] =
  result.add "size: sizeof(cint)"

  if header.len > 0:
    let cName = &"enum {name}"
    result.add importc(cName, renamed)
    result.add(&"header: \"{header}\"")


proc enumDecl*(node: JsonNode, renamer: Renamer, header: string = "", prefix: string = ""): (string, string) =
  let constants = node.inner.getElems.filterIt(it.isEnumConstantDeclaration)

  if constants.len == 0:
    return ("", "")

  let (uniqueConstants, duplicateConstants) = deduplicateConstants(constants)
  let name = (if prefix.len > 0: &"{prefix}_" else: "") & node.resolveName
  let (renamed, userPragmas) = renamer(EnumType, name)
  let pragmas = pragmas(enumPragmas(header, name, renamed) & userPragmas)
  result[0] = &"  {renamed}*" & pragmas & " = enum\n"

  let constantDeclarations = uniqueConstants.mapIt(it.enumConstant(renamer))
  result[0] &= constantDeclarations.join(",\n") & "\n"

  for constant in duplicateConstants:
    let value = explicitValue(constant)
    let (constantName, _) = renamer(EnumValue, constant.name)
    result[1] &= &"template {constantName}*(_: typedesc[{renamed}]): {renamed} = {value}\n"

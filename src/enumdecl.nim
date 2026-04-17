import std/[json, strutils, strformat, sequtils]
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


proc `enum`*(node: JsonNode, renamer: Renamer): string =
  let constants = node.inner.getElems.filterIt(it.isEnumConstantDeclaration)
  let hasEnumConstants = constants.len > 0

  if not hasEnumConstants:
    return ""

  let (renamed, userPragmas) = renamer(EnumType, node.name)
  let pragmas = pragmas(@["size: sizeof(cint)"] & userPragmas)
  result = &"  {renamed}*" & pragmas & " = enum\n"

  let constantDeclarations = constants.mapIt(it.enumConstant(renamer))
  result &= constantDeclarations.join(",\n") & "\n"

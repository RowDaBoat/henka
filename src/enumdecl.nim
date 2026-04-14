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
  if hasValue: &"  {renamed}{pragmas} = {value}"
  else: &"  {renamed}{pragmas}"


proc `enum`*(node: JsonNode, renamer: Renamer): string =
  let inner = node.inner

  if inner.isNil or inner.kind != JArray:
    return

  let (renamed, userPragmas) = renamer(EnumType, node.name)
  let pragmas = pragmas(@["size: sizeof(cint)"] & userPragmas)
  result = &"type {renamed}*" & pragmas & " = enum\n"

  let constants = inner.getElems
    .filterIt(it.isEnumConstantDeclaration)
    .mapIt(it.enumConstant(renamer))

  result &= constants.join(",\n") & "\n"

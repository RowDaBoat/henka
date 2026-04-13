import std/[json, strutils, strformat, sequtils]
import node, renamer


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
  let renamed = renamer(EnumValue, constant.name)
  if hasValue: &"  {renamed} = {value}"
  else: &"  {renamed}"


proc `enum`*(node: JsonNode, renamer: Renamer): string =
  let inner = node.inner

  if inner.isNil or inner.kind != JArray:
    return

  let renamed = renamer(EnumType, node.name)
  result = &"type {renamed}* " & "{.size: sizeof(cint).} = enum\n"

  let constants = inner.getElems
    .filterIt(it.isEnumConstantDeclaration)
    .mapIt(it.enumConstant(renamer))

  result &= constants.join(",\n") & "\n"

import std/[json, strutils, strformat, sequtils]
import node


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


proc enumConstant(constant: JsonNode): string =
  let value = explicitValue(constant)
  let hasValue = value.len > 0
  if hasValue: &"  {constant.name} = {value}"
  else: &"  {constant.name}"


proc `enum`*(node: JsonNode): string =
  let inner = node.inner

  if inner.isNil or inner.kind != JArray:
    return

  result = &"type {node.name}* " & "{.size: sizeof(cint).} = enum\n"

  let constants = inner.getElems
    .filterIt(it.isEnumConstantDeclaration)
    .mapIt(it.enumConstant)

  result &= constants.join(",\n") & "\n"

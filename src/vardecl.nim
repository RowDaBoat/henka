import std/[json, strutils, strformat]
import node, types


proc extractLiteralValue(node: JsonNode): string =
  let kind = node.astKind

  if kind in ["IntegerLiteral", "FloatingLiteral"]:
    return node.value

  let inner = node.inner
  let hasNoInner = inner.isNil or inner.kind != JArray or inner.len == 0
  if hasNoInner: return ""

  extractLiteralValue(inner[0])


proc isStaticConst(node: JsonNode): bool =
  node.storageClass == "static"


proc vardecl*(node: JsonNode, header: string): string =
  let nimType = qualTypeToNim(node.typ)

  if node.isStaticConst:
    let inner = node.inner
    let hasValue = not inner.isNil and inner.kind == JArray and inner.len > 0
    let literalValue = if hasValue: extractLiteralValue(inner[0]) else: ""
    return &"const {node.name}*: {nimType} = {literalValue}"

  var pragmas = @["importc"]

  if header.len > 0:
    pragmas.add(&"header: \"{header}\"")

  let pragmaStr = "{." & pragmas.join(", ") & ".}"
  &"var {node.name}* {pragmaStr}: {nimType}"

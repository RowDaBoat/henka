import std/[json, strutils, strformat]
import node, types, renamer


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


proc vardecl*(node: JsonNode, header: string, renamer: Renamer): string =
  let nimType = qualTypeToNim(node.typ, renamer)

  if node.isStaticConst:
    let inner = node.inner
    let hasValue = not inner.isNil and inner.kind == JArray and inner.len > 0
    let renamed = renamer(Constant, node.name)
    let literalValue = if hasValue: extractLiteralValue(inner[0]) else: ""
    return &"const {renamed}*: {nimType} = {literalValue}"

  var pragmas = @["importc"]

  if header.len > 0:
    pragmas.add(&"header: \"{header}\"")

  let renamed = renamer(Variable, node.name)
  let pragmaStr = "{." & pragmas.join(", ") & ".}"
  &"var {renamed}* {pragmaStr}: {nimType}"

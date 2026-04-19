import std/[json, strformat, strutils]
import node, types, renamer, pragmas


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


proc varPragmas(name: string, renamed: string, header: string): seq[string] =
  result = @[importc(name, renamed)]

  if header.len > 0:
    result.add(&"header: \"{header}\"")


proc vardecl*(node: JsonNode, header: string, renamer: Renamer): string =
  let nimType = qualTypeToNim(node.typ, renamer)

  if node.isStaticConst:
    let inner = node.inner
    let hasValue = not inner.isNil and inner.kind == JArray and inner.len > 0
    let (renamed, userPragmas) = renamer(Constant, node.name)
    let pragmas = pragmas(userPragmas)
    let rawValue = if hasValue: extractLiteralValue(inner[0]) else: ""
    let needsU64Suffix = rawValue.len > 0 and rawValue.parseBiggestUInt > high(int32).uint64
    let literalValue = if needsU64Suffix: rawValue & "'u64" else: rawValue
    return &"const {renamed}*{pragmas}: {nimType} = {literalValue}"

  let (renamed, userPragmas) = renamer(Variable, node.name)
  let pragmas = pragmas(varPragmas(node.name, renamed, header) & userPragmas)
  &"var {renamed}*{pragmas}: {nimType}"

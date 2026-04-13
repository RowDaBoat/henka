import std/[json, strformat]
import node, renamer
import types

proc typedef*(node: JsonNode, renamer: Renamer): string =
  let inner = node.inner

  if inner.isNil or inner.kind != JArray or inner.len == 0:
    return

  let (renamed, userPragmas) = renamer(Typedef, node.name)
  let pragmas = pragmas(userPragmas)
  &"type {renamed}*{pragmas} = {inner[0].astTypeToNim}"

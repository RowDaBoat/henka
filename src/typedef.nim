import std/[json, strformat]
import node
import types

proc typedef*(node: JsonNode): string =
  let inner = node.inner

  if inner.isNil or inner.kind != JArray or inner.len == 0:
    return

  &"type {node.name}* = {inner[0].astTypeToNim}"

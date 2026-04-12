import std/[json, strutils, strformat]
import node, types


proc vardecl*(node: JsonNode, header: string): string =
  let nimType = qualTypeToNim(node.typ)
  var pragmas = @["importc"]

  if header.len > 0:
    pragmas.add(&"header: \"{header}\"")

  let pragmaStr = "{." & pragmas.join(", ") & ".}"
  &"var {node.name}* {pragmaStr}: {nimType}"

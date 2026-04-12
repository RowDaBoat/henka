import std/[json, strutils, strformat, sequtils]
import node
import types


proc pragmasFrom(tag: string, header: string): string =
  var pragmas = @["importc"]

  if tag == "union":
    pragmas.add "union"
  else:
    pragmas.add "bycopy"

  if header.len > 0:
    pragmas.add(&"header: \"{header}\"")

  result = "{." & pragmas.join(", ") & ".}"


proc isFieldDeclaration(node: JsonNode): bool =
  node.astKind == "FieldDecl"


proc record*(node: JsonNode, header: string): string =
  let tag = node.tag
  let inner = node.inner
  let pragmas = pragmasFrom(tag, header)
  result = &"type {node.name}* {pragmas} = object\n"

  if inner.isNil or inner.kind != JArray:
    return

  for field in inner.getElems.filterIt(it.isFieldDeclaration):
    let nimType = qualTypeToNim(field.typ)
    result &= &"  {field.name}*: {nimType}\n"

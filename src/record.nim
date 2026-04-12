import std/[json, strutils, strformat, sequtils]
import node, types, renamer


proc pragmasFrom(isUnion: bool, header: string): string =
  var pragmas = @["importc"]

  pragmas.add (if isUnion: "union" else: "bycopy")

  if header.len > 0:
    pragmas.add(&"header: \"{header}\"")

  result = "{." & pragmas.join(", ") & ".}"


proc isFieldDeclaration(node: JsonNode): bool =
  node.astKind == "FieldDecl"


proc record*(node: JsonNode, header: string, renamer: Renamer): string =
  let isUnion = node.tag == "union"
  let pragmas = pragmasFrom(isUnion, header)
  let nimObject = renamer(StructType, node.name)
  result = &"type {nimObject}* {pragmas} = object\n"

  let inner = node.inner
  if inner.isNil or inner.kind != JArray:
    return

  for field in inner.getElems.filterIt(it.isFieldDeclaration):
    let nimType = qualTypeToNim(field.typ, renamer)
    let nimField = renamer(Field, field.name)
    result &= &"  {nimField}*: {nimType}\n"

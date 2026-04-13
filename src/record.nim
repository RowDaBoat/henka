import std/[json, strformat, sequtils]
import node, types, renamer


proc recordPragmas(isUnion: bool, header: string): seq[string] =
  result = @["importc"]
  result.add (if isUnion: "union" else: "bycopy")

  if header.len > 0:
    result.add(&"header: \"{header}\"")


proc isFieldDeclaration(node: JsonNode): bool =
  node.astKind == "FieldDecl"


proc record*(node: JsonNode, header: string, renamer: Renamer): string =
  let isUnion = node.tag == "union"
  let recordKind = if isUnion: UnionType else: StructType
  let (nimObject, userPragmas) = renamer(recordKind, node.name)
  let pragmas = pragmas(recordPragmas(isUnion, header) & userPragmas)
  result = &"type {nimObject}*{pragmas} = object\n"

  let inner = node.inner
  if inner.isNil or inner.kind != JArray:
    return

  for field in inner.getElems.filterIt(it.isFieldDeclaration):
    let nimType = qualTypeToNim(field.typ, renamer)
    let (nimField, userPragmas) = renamer(Field, field.name)
    let pragmas = pragmas(userPragmas)
    result &= &"  {nimField}*{pragmas}: {nimType}\n"

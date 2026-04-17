import std/[json, strformat, sequtils]
import node, types, renamer, pragmas


proc recordPragmas(isUnion: bool, isForwardDeclaration: bool, header: string): seq[string] =
  if isForwardDeclaration:
    result.add "incompleteStruct"
  elif isUnion:
    result.add "union"
  else:
    result.add "bycopy"

  let hasHeader = header.len > 0
  let shouldIncludeHeader = hasHeader and not isForwardDeclaration
  if shouldIncludeHeader:
    result.add(&"header: \"{header}\"")


proc isFieldDeclaration(node: JsonNode): bool =
  node.astKind == "FieldDecl"


proc record*(node: JsonNode, header: string, renamer: Renamer): string =
  let isUnion = node.tag == "union"
  let recordKind = if isUnion: UnionType else: StructType
  let (renamed, userPragmas) = renamer(recordKind, node.resolveName)
  let pragmas = pragmas(recordPragmas(isUnion, node.isForwardDeclaration, header) & userPragmas)

  result = &"  {renamed}*{pragmas} = object\n"

  if not node.isForwardDeclaration:
    for field in node.inner.getElems.filterIt(it.isFieldDeclaration):
      let nimType = qualTypeToNim(field.typ, renamer)
      let (renamed, userPragmas) = renamer(Field, field.name)
      let pragmas = pragmas(userPragmas)
      result &= &"    {renamed}*{pragmas}: {nimType}\n"

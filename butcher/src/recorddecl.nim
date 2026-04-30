import std/[json, strformat, strutils, tables]
import node, types, renamer, pragmas, enumdecl


proc recordPragmas(isUnion: bool, isForwardDeclaration: bool, header: string, name: string, renamed: string): seq[string] =
  if isForwardDeclaration:
    result.add "incompleteStruct"
  elif isUnion:
    result.add "union"
  else:
    result.add "bycopy"

  let hasHeader = header.len > 0
  if hasHeader:
    let tag = if isUnion: "union" else: "struct"
    let cName = &"{tag} {name}"
    result.add importc(cName, renamed)
    result.add(&"header: \"{header}\"")


proc isFieldDeclaration(node: JsonNode): bool =
  node.astKind == "FieldDecl"


proc isNestedRecordDeclaration(node: JsonNode): bool =
  node.astKind == "RecordDecl"


proc isNestedEnumDeclaration(node: JsonNode): bool =
  node.astKind == "EnumDecl"


proc fieldDeclaration(field: JsonNode, lastNestedType: string, nestedNames: Table[string, string], renamer: Renamer, anonymousIndex: var int): string =
  let qualType = field.typ.qualType
  let isAnonymousField = "unnamed" in qualType or "anonymous" in qualType
  let fieldName = if field.name.len == 0: &"unnamed{anonymousIndex}" else: field.name
  let (renamed, userPragmas) = renamer(Field, fieldName)
  let pragmas = pragmas(userPragmas)

  if field.name.len == 0:
    inc anonymousIndex

  if isAnonymousField:
    return &"    {renamed}*{pragmas}: {lastNestedType}\n"

  let qualTypeParts = qualType.split(" ", 1)
  let fieldTypeName = if qualTypeParts.len > 1: qualTypeParts[1] else: ""
  let nimType = nestedNames.getOrDefault(fieldTypeName, qualTypeToNim(field.typ, renamer))
  return &"    {renamed}*{pragmas}: {nimType}\n"


proc nestedTypeName(child: JsonNode, parentName: string, renamer: Renamer): string =
  let nestedName = &"{parentName}_{child.resolveName}"
  if child.isNestedEnumDeclaration:
    renamer(EnumType, nestedName)[0]
  elif child.tag == "union":
    renamer(UnionType, nestedName)[0]
  else:
    renamer(StructType, nestedName)[0]


proc recordDecl*(node: JsonNode, header: string, renamer: Renamer, prefix: string = ""): (string, string)


proc nestedDeclarations(node: JsonNode, parentName: string, header: string, renamer: Renamer): (string, string, Table[string, string]) =
  for child in node.inner.getElems:
    if child.isNestedRecordDeclaration:
      let (recordResult, aliases) = recordDecl(child, header, renamer, parentName)
      result[0] &= recordResult
      result[1] &= aliases
      result[2][child.name] = nestedTypeName(child, parentName, renamer)
    elif child.isNestedEnumDeclaration:
      let (enumResult, aliases) = enumDecl(child, renamer, header, parentName)
      result[0] &= enumResult
      result[1] &= aliases
      result[2][child.name] = nestedTypeName(child, parentName, renamer)


proc recordDecl*(node: JsonNode, header: string, renamer: Renamer, prefix: string = ""): (string, string) =
  let isUnion = node.tag == "union"
  let recordKind = if isUnion: UnionType else: StructType
  let name = (if prefix.len > 0: &"{prefix}_" else: "") & node.resolveName
  let (renamed, userPragmas) = renamer(recordKind, name)
  let pragmas = pragmas(recordPragmas(isUnion, node.isForwardDeclaration, header, name, renamed) & userPragmas)

  var nestedNames: Table[string, string]

  if node.isForwardDeclaration:
    result[0] &= &"  {renamed}*{pragmas} = object\n"
    return

  let (recordResult, aliases, names) = nestedDeclarations(node, name, header, renamer)

  if recordResult.len > 0:
    result[0] &= recordResult & "\n"

  result[0] &= &"  {renamed}*{pragmas} = object\n"
  result[1] &= aliases
  nestedNames = names

  var lastNestedType = ""
  var anonymousIndex = 0

  for child in node.inner.getElems:
    if child.isNestedRecordDeclaration or child.isNestedEnumDeclaration:
      lastNestedType = nestedTypeName(child, name, renamer)

    if child.isFieldDeclaration:
      result[0] &= fieldDeclaration(child, lastNestedType, nestedNames, renamer, anonymousIndex)


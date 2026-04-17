import std/json


proc inner*(node: JsonNode): JsonNode =
  node.getOrDefault("inner")

proc id*(node: JsonNode): string =
  node.getOrDefault("id").getStr

proc name*(node: JsonNode): string =
  node.getOrDefault("name").getStr

proc unnamed*(node: JsonNode): string =
  "Unnamed" & node.id

proc resolveName*(node: JsonNode): string =
  if node.name == "": node.unnamed else: node.name

proc ownedTagDecl*(node: JsonNode): JsonNode =
  node.getOrDefault("ownedTagDecl")

proc decl*(node: JsonNode): JsonNode =
  node.getOrDefault("decl")

proc size*(node: JsonNode): int =
  node.getOrDefault("size").getInt

proc typ*(node: JsonNode): JsonNode =
  node.getOrDefault("type")

proc qualType*(node: JsonNode): string =
  node.getOrDefault("qualType").getStr

proc astKind*(node: JsonNode): string =
  node.getOrDefault("kind").getStr

proc isImplicit*(node: JsonNode): bool =
  node.getOrDefault("isImplicit").getBool(false)

proc isInvalid*(node: JsonNode): bool =
  node.getOrDefault("isInvalid").getBool(false)

proc isVariadic*(node: JsonNode): bool =
  node.getOrDefault("variadic").getBool(false)

proc isForwardDeclaration*(node: JsonNode): bool =
  not node.getOrDefault("completeDefinition").getBool(false)

proc isAnonymous*(node: JsonNode): bool =
  node.getOrDefault("name").getStr == ""

proc location*(node: JsonNode): JsonNode =
  node.getOrDefault("loc")

proc file*(node: JsonNode): string =
  node.getOrDefault("file").getStr

proc tag*(node: JsonNode): string =
  node.getOrDefault("tagUsed").getStr

proc storageClass*(node: JsonNode): string =
  node.getOrDefault("storageClass").getStr

proc value*(node: JsonNode): string =
  node.getOrDefault("value").getStr

import std/[json, os, strformat, sets, sequtils]
import node, record, enumdecl, typedef, function, vardecl, error, compileast, renamer


proc isUserDeclaration(node: JsonNode): bool =
  let location = node.location
  let hasLocation = not location.isNil and location.kind == JObject and location.len > 0
  not node.isImplicit and not node.isInvalid and hasLocation


proc updateLocation(declaration: JsonNode, current: var string) =
  let newLocation = declaration.location.file

  if newLocation.len > 0:
    current = newLocation


proc bindingFor(
  declaration: JsonNode, 
  headerFile: string, 
  emitted: var HashSet[string],
  renamer: Renamer
): string =
  let kind = declaration.astKind
  let name = declaration.name

  case kind
  of "RecordDecl":
    emitted.incl(name)
    return record(declaration, headerFile, renamer)

  of "EnumDecl":
    emitted.incl(name)
    return `enum`(declaration)

  of "FunctionDecl":
    return function(declaration, headerFile)

  of "TypedefDecl":
    if not (name in emitted):
      return typedef(declaration)

  of "VarDecl":
    return vardecl(declaration, headerFile)

  of "StaticAssertDecl", "EmptyDecl":
    return ""

  else: error &"Henka does not support '{kind}' declarations yet."


proc generateAst*(header: string): string =
  compileAstFrom(header)


proc generateBindings*(jsonAst: string, renamer: Renamer = defaultRenamer): string =
  let root = jsonAst.parseJson()
  let declarations = root.inner

  if declarations.isNil or declarations.kind != JArray:
    return

  var emitted: HashSet[string]
  var headerFile = ""

  for declaration in declarations.filterIt(it.isUserDeclaration):
    declaration.updateLocation(headerFile)

    if not headerFile.isAbsolute:
      let binding = bindingFor(declaration, headerFile, emitted, renamer)
      if binding.len > 0:
        result &= binding & "\n"


when isMainModule:
  if paramCount() < 1:
    echo "Usage: henka <header.h>"
    quit(1)

  let header = paramStr(1)
  let jsonAst = generateAst(header)
  writeFile(&"{splitFile(header)[1]}.json", jsonAst)
  stdout.write generateBindings(jsonAst)

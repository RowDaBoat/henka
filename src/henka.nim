import std/[json, os, strformat, sets, strutils, sequtils]
import node, record, enumdecl, typedef, function, vardecl, error, compileast, renamer
import cliquet
export renamer


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
    return `enum`(declaration, renamer)

  of "FunctionDecl":
    return function(declaration, headerFile, renamer)

  of "TypedefDecl":
    if not (name in emitted):
      return typedef(declaration, renamer)

  of "VarDecl":
    return vardecl(declaration, headerFile, renamer)

  of "StaticAssertDecl", "EmptyDecl":
    return ""

  else: error &"Henka does not support '{kind}' declarations yet."


proc generateAst*(headers: seq[string], clangArgs: string = ""): string =
  compileAstFrom(headers, clangArgs)


proc generateBindings*(jsonAst: string, renamer: Renamer = defaultRenamer): string =
  let root = jsonAst.parseJson()
  let declarations = root.inner

  if declarations.isNil or declarations.kind != JArray:
    return

  let projectDir = getCurrentDir()
  var emitted: HashSet[string]
  var headerFile = ""

  for declaration in declarations.filterIt(it.isUserDeclaration):
    declaration.updateLocation(headerFile)

    if headerFile.startsWith(projectDir):
      let relativeHeaderFile = headerFile.relativePath(projectDir)
      let binding = bindingFor(declaration, relativeHeaderFile, emitted, renamer)

      if binding.len > 0:
        result &= binding & "\n"


type CliConfig = object
  help      {.help: "Show this help message", shortOption: 'h', mode: option.}           : bool
  clangargs {.help: "Forward arguments to clang".}                                       : string
  astout    {.help: "Output the generated JSON AST to this path".}                       : string
  nimout    {.help: "Output the generated Nim bindings to this path (default: stdout)".} : string
  jsonast   {.help: "Use an existing JSON AST instead of invoking clang".}               : string


when isMainModule:
  var cli = initCliquet(CliConfig())
  let headers = cli.parseOptions(commandLineParams())
  let config = cli.config()
  let usage = "Usage: henka [options] <header.h> [header.h ...]"
  let help = usage & "\n" & cli.generateHelp()

  if config.help:
    echo help
    quit(0)

  let hasInput = config.jsonast.len > 0 or headers.len > 0
  if not hasInput:
    echo help
    quit(1)

  let jsonAst = case config.jsonast.len > 0:
  of true:  readFile(config.jsonast)
  of false: generateAst(headers, config.clangargs)

  if config.astout.len > 0:
    writeFile(config.astout, jsonAst)

  let bindings = generateBindings(jsonAst)

  case config.nimout.len > 0:
  of true:  writeFile(config.nimout, bindings)
  of false: stdout.write bindings

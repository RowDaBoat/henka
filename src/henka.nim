import std/[json, os, strformat, sets, strutils, sequtils]
import node, recordDecl, enumDecl, typedefDecl, functionDecl, varDecl, error, compileast, renamer
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


proc collectCompleteRecords(declarations: JsonNode, projectDir: string): HashSet[string] =
  var headerFile = ""

  for declaration in declarations.getElems.filterIt(it.isUserDeclaration):
    declaration.updateLocation(headerFile)

    let isRecordDeclaration = declaration.astKind == "RecordDecl"
    let isProjectFile = headerFile.startsWith(projectDir)
    let isCompleteDefinition = not declaration.isForwardDeclaration

    let shouldCollect = isRecordDeclaration and isProjectFile and isCompleteDefinition
    if shouldCollect:
      result.incl(declaration.resolveName)


proc typeBindingFor(
  declaration: JsonNode,
  headerFile: string,
  completeRecords: HashSet[string],
  forwardDeclarations: var HashSet[string],
  renamer: Renamer
): (string, string) =
  let kind = declaration.astKind

  case kind
  of "RecordDecl":
    let isForwardDeclaration = declaration.isForwardDeclaration
    let hasCompleteDefinition = declaration.resolveName in completeRecords
    let isDuplicateForwardDeclaration = isForwardDeclaration and declaration.resolveName in forwardDeclarations

    if (isForwardDeclaration and hasCompleteDefinition) or isDuplicateForwardDeclaration:
      return ("", "")

    if isForwardDeclaration:
      forwardDeclarations.incl(declaration.resolveName)

    return recordDecl(declaration, headerFile, renamer)

  of "EnumDecl":
    return enumDecl(declaration, renamer)

  of "TypedefDecl":
    return (typedefDecl(declaration, renamer), "")

  of "VarDecl", "FunctionDecl", "StaticAssertDecl", "EmptyDecl":
    return ("", "")

  else: error &"Henka does not support '{kind}' declarations yet."


proc varOrFuncBindingFor(declaration: JsonNode, headerFile: string, renamer: Renamer): string =
  let kind = declaration.astKind

  case kind
  of "VarDecl":
    return varDecl(declaration, headerFile, renamer)

  of "FunctionDecl":
    return functionDecl(declaration, headerFile, renamer)

  of "RecordDecl", "EnumDecl", "TypedefDecl", "StaticAssertDecl", "EmptyDecl":
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
  let completeRecords = collectCompleteRecords(declarations, projectDir)

  var headerFile = ""
  var types = ""
  var forwardDeclarations: HashSet[string]
  var dupedEnums = ""

  for declaration in declarations.filterIt(it.isUserDeclaration):
    declaration.updateLocation(headerFile)

    if headerFile.startsWith(projectDir):
      let relativeHeaderFile = headerFile.relativePath(projectDir)
      let (binding, dupedEnumValues) = typeBindingFor(declaration, relativeHeaderFile, completeRecords, forwardDeclarations, renamer)

      dupedEnums &= dupedEnumValues

      if binding.len > 0:
        types &= binding & "\n"

  if types.len > 0:
    types = "type\n" & types & "\n" & dupedEnums

  headerFile = ""
  var varsAndFuncs = ""

  for declaration in declarations.filterIt(it.isUserDeclaration):
    declaration.updateLocation(headerFile)

    if headerFile.startsWith(projectDir):
      let relativeHeaderFile = headerFile.relativePath(projectDir)
      let binding = varOrFuncBindingFor(declaration, relativeHeaderFile, renamer)

      if binding.len > 0:
        varsAndFuncs &= binding & "\n"

  result = types & "\n" & varsAndFuncs


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

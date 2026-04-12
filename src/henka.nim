import std/[json, os, strformat, sets, sequtils]
import node
import record
import enumdecl
import typedef
import function
import vardecl
import error
import compileast

proc isUserDeclaration(node: JsonNode): bool =
  let location = node.location
  let hasLocation = not location.isNil and location.kind == JObject and location.len > 0
  not node.isImplicit and not node.isInvalid and hasLocation


proc emit(s: string) = echo s


proc getHeaderPath(): string =
  if paramCount() < 1:
    echo "Usage: listdecls <header.h>"
    quit(1)

  paramStr(1)


proc declarationsFrom(root: JsonNode): JsonNode =
  result = root.inner

  if result.isNil or result.kind != JArray:
    echo "No top-level declarations found."
    quit(0)


proc updateLocation(declaration: JsonNode, current: var string) =
  let newLocation = declaration.location.file

  if newLocation.len > 0:
    current = newLocation


proc emit(declaration: JsonNode, headerFile: string, emitted: var HashSet[string]) =
  let kind = declaration.astKind
  let name = declaration.name

  case kind
  of "RecordDecl":
    emit record(declaration, headerFile)
    emitted.incl(name)

  of "EnumDecl":
    emit `enum`(declaration)
    emitted.incl(name)

  of "FunctionDecl":
    emit function(declaration, headerFile)

  of "TypedefDecl":
    if not (name in emitted):
      emit typedef(declaration)

  of "VarDecl":
    emit vardecl(declaration, headerFile)

  of "StaticAssertDecl", "EmptyDecl":
    discard

  else: error &"Henka does not support '{kind}' declarations yet."


when isMainModule:
  let header = getHeaderPath()
  let jsonAst = compileAstFrom(header)
  writeFile(&"{splitFile(header)[1]}.json", jsonAst)
  let root = jsonAst.parseJson()
  let declarations = declarationsFrom(root)

  var emitted: HashSet[string]
  var headerFile = ""

  for declaration in declarations.filterIt(it.isUserDeclaration):
    declaration.updateLocation(headerFile)

    if not headerFile.isAbsolute:
      emit declaration, headerFile, emitted

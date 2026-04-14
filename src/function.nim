import std/[json, strutils, strformat, sequtils]
import node, types, renamer, pragmas


proc functionPragmas(name: string, renamed: string, header: string, isVariadic: bool): seq[string] =
  result = @[importcPragma(name, renamed), "cdecl"]

  if isVariadic:
    result.add("varargs")

  if header.len > 0:
    result.add(&"header: \"{header}\"")


proc isParameterDeclaration(node: JsonNode): bool =
  node.astKind == "ParmVarDecl"


proc function*(node: JsonNode, header: string, renamer: Renamer): string =
  let inner = node.inner

  if inner.isNil or inner.kind != JArray:
    return

  let nimReturnType = node.typ.returnTypeToNim(renamer)

  var parameters: seq[string]

  for parameter in inner.getElems.filterIt(it.isParameterDeclaration):
    let (renamed, userPragmas) = renamer(Parameter, parameter.name)
    let pragmas = pragmas(userPragmas)
    let parameterType = qualTypeToNim(parameter.typ, renamer)
    parameters.add(renamed & pragmas & ": " & parameterType)

  let (renamed, userPragmas) = renamer(Proc, node.name)
  let joinedParameters = parameters.join(", ")
  let pragmas = pragmas(functionPragmas(node.name, renamed, header, node.isVariadic) & userPragmas)
  let `return` = if nimReturnType == "void": "" else: &": {nimReturnType}"
  result = &"proc {renamed}*({joinedParameters}){`return`}{pragmas}"

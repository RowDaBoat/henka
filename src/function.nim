import std/[json, strutils, strformat, sequtils]
import node, types, renamer


proc pragmasFrom(header: string, isVariadic: bool): string =
  var pragmas = @["importc", "cdecl"]

  if isVariadic:
    pragmas.add("varargs")

  if header.len > 0:
    pragmas.add(&"header: \"{header}\"")

  result = "{." & pragmas.join(", ") & ".}"


proc isParameterDeclaration(node: JsonNode): bool =
  node.astKind == "ParmVarDecl"


proc function*(node: JsonNode, header: string, renamer: Renamer): string =
  let inner = node.inner

  if inner.isNil or inner.kind != JArray:
    return

  let nimReturnType = node.typ.returnTypeToNim(renamer)

  var parameters: seq[string]

  for parameter in inner.getElems.filterIt(it.isParameterDeclaration):
    let renamed = renamer(Parameter, parameter.name)
    let parameterType = qualTypeToNim(parameter.typ, renamer)
    parameters.add(renamed & ": " & parameterType)

  let renamed = renamer(Proc, node.name)
  let joinedParameters = parameters.join(", ")
  let pragmas = pragmasFrom(header, node.isVariadic)
  let `return` = if nimReturnType == "void": " " else: &": {nimReturnType}"
  result = &"proc {renamed}*({joinedParameters}){`return`} {pragmas}"

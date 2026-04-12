import std/[json, strutils, strformat, sequtils]
import node, types


proc pragmasFrom(header: string, isVariadic: bool): string =
  var pragmas = @["importc", "cdecl"]

  if isVariadic:
    pragmas.add("varargs")

  if header.len > 0:
    pragmas.add(&"header: \"{header}\"")

  result = "{." & pragmas.join(", ") & ".}"


proc isParameterDeclaration(node: JsonNode): bool =
  node.astKind == "ParmVarDecl"


proc function*(node: JsonNode, header: string): string =
  let inner = node.inner

  if inner.isNil or inner.kind != JArray:
    return

  let nimReturnType = node.typ.returnTypeToNim

  var parameters: seq[string]

  for param in inner.getElems.filterIt(it.isParameterDeclaration):
    let parameterType = qualTypeToNim(param.typ)
    parameters.add(param.name & ": " & parameterType)

  let pragmas = pragmasFrom(header, node.isVariadic)
  let joinedParameters = parameters.join(", ")
  let `return` = if nimReturnType == "void": " " else: &": {nimReturnType}"
  result = &"proc {node.name}*({joinedParameters}){`return`} {pragmas}"

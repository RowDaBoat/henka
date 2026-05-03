# @deps std
from std/os import lastPathPart, relativePath
from std/strutils import join
# @deps slate
import slate/ast as astTF
# deps henka
import ./[clang, common]


proc qualifiedName*(cursor: CXCursor): system.string =
  var parts: seq[system.string] = @[]
  var current = cursor

  while true:
    let parent     = clang_getCursorSemanticParent(current)
    let parentKind = clang_getCursorKind(parent)

    if parentKind == CXCursor_Namespace:
      parts.add parent.spelling
      current = parent
    elif parentKind == CXCursor_ClassDecl or parentKind == CXCursor_StructDecl:
      parts.add parent.spelling
      current = parent
    else:
      break

  if parts.len == 0:
    return cursor.spelling

  var reversed: seq[system.string] = @[]

  for idx in countdown(parts.len - 1, 0):
    reversed.add parts[idx]

  reversed.add cursor.spelling
  result = reversed.join("::")


proc addPragma*(conv: var Converter; name: string; value: string = ""): astTF.Id =
  let keyName = conv.addName(name)
  let keyExpr = conv.ast.add_expression(Expression(kind: astTF.eIdentifier, identifier: ExpressionIdentifier(name: keyName)))
  var pragmaValue: Option[astTF.Id] = none(astTF.Id)

  if value.len > 0:
    let valLoc = conv.addSrc(value)
    let valExpr = conv.ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.string, value: valLoc)))
    pragmaValue = some(valExpr)

  result = conv.ast.add_pragma(Pragma(key: keyExpr, value: pragmaValue))


proc headerPragma*(conv: Converter): (system.string, system.string) =
  let path = case conv.rootDir.len > 0
    of true:  conv.headerFile.relativePath(conv.rootDir)
    of false: conv.headerFile.lastPathPart
  result = ("header", "\"" & path & "\"")


proc linkPragma*(conv: Converter): (system.string, system.string)=
  case conv.linkMode
  of LinkMode.header: result = conv.headerPragma
  of LinkMode.dynlib: result = ("dynlib", conv.dynlibName)


proc chainPragmas*(conv: var Converter; pairs: seq[(system.string, system.string)]): astTF.Id =
  var current: Option[astTF.Id] = none(astTF.Id)

  for idx in countdown(pairs.len - 1, 0):
    let pragmaId = conv.addPragma(pairs[idx][0], pairs[idx][1])
    if current.isSome:
      conv.ast.data.pragmas[pragmaId].next = current
    current = some(pragmaId)

  result = current.get


proc classPragmas*(conv: var Converter; cursor: CXCursor; isForward: bool): astTF.Id =
  var pairs: seq[(system.string, system.string)] = @[]

  if isForward:
    pairs.add ("incompleteStruct", "")

  pairs.add ("importcpp", "\"" & cursor.qualifiedName & "\"")
  pairs.add conv.headerPragma
  result = conv.chainPragmas(pairs)


proc methodPragmas*(conv: var Converter; cursor: CXCursor): astTF.Id =
  let name = cursor.spelling
  result = conv.chainPragmas(@[
    ("importcpp", "\"#." & name & "(@)\""),
    conv.linkPragma])


proc constructorPragmas*(conv: var Converter; cursor: CXCursor): astTF.Id =
  let parentCursor = clang_getCursorSemanticParent(cursor)
  let qualified = parentCursor.qualifiedName
  result = conv.chainPragmas(@[
    ("importcpp",   "\"" & qualified & "(@)\""),
    ("constructor", ""),
    conv.linkPragma
  ])


proc destructorPragmas*(conv: var Converter; cursor: CXCursor): astTF.Id =
  let className = clang_getCursorSemanticParent(cursor).spelling
  result = conv.chainPragmas(@[
    ("importcpp", "\"#.~" & className & "()\""),
    conv.linkPragma
  ])


proc staticMethodPragmas*(conv: var Converter; cursor: CXCursor): astTF.Id =
  let qualified = cursor.qualifiedName
  result = conv.chainPragmas(@[
    ("importcpp", "\"" & qualified & "(@)\""),
    conv.linkPragma
  ])


proc importPragmaKey*(conv: Converter): system.string =
  if conv.isCpp: "importcpp"
  else:          "importc"


proc structPragmas*(conv: var Converter; cName: system.string; isForward: bool; isTagged: bool = true; isUnion: bool = false): astTF.Id =
  var pairs: seq[(system.string, system.string)] = @[]

  if isForward:
    pairs.add ("incompleteStruct", "")
  elif not conv.isCpp:
    pairs.add ("bycopy", "")

  if conv.linkMode != LinkMode.dynlib:
    let tag = if isUnion: "union " else: "struct "
    let importValue =
      if conv.isCpp: "\"" & cName & "\""
      elif isTagged: "\"" & tag & cName & "\""
      else:          "\"" & cName & "\""

    pairs.add (conv.importPragmaKey, importValue)
    pairs.add conv.headerPragma

  if conv.pragmaOverride != nil:
    let labelKind = if isUnion: UnionType else: StructType
    pairs = conv.pragmaOverride(labelKind, cName, pairs)

  result = conv.chainPragmas(pairs)


proc enumPragmas*(conv: var Converter; cName: system.string): astTF.Id =
  var pairs: seq[(system.string, system.string)] = @[]
  pairs.add ("size", "sizeof(cint)")

  if conv.linkMode != LinkMode.dynlib:
    let importValue = case conv.isCpp:
      of true:  "\"" & cName & "\""
      of false: "\"enum " & cName & "\""

    pairs.add (conv.importPragmaKey, importValue)
    pairs.add conv.headerPragma

  if conv.pragmaOverride != nil:
    pairs = conv.pragmaOverride(EnumType, cName, pairs)

  result = conv.chainPragmas(pairs)


proc funcPragmas*(conv: var Converter; cName: system.string): astTF.Id =
  var pairs: seq[(system.string, system.string)] = @[]

  if conv.isCpp:
    pairs.add (conv.importPragmaKey, "\"" & cName & "(@)\"")
    pairs.add conv.linkPragma
  else:
    pairs.add (conv.importPragmaKey, "\"" & cName & "\"")
    pairs.add ("cdecl", "")
    pairs.add conv.linkPragma

  if conv.pragmaOverride != nil:
    pairs = conv.pragmaOverride(Proc, cName, pairs)

  result = conv.chainPragmas(pairs)

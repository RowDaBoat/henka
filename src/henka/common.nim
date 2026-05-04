# @deps std
from std/strutils import startsWith
# @deps slate
import slate/ast as astTF
# @deps henka
import ./base
export base


const OperatorPatterns* :seq[(system.string, system.string, system.string)]= @[
  ("operator+",  "`+`",  "\"# + #\""),
  ("operator-",  "`-`",  ""),
  ("operator*",  "`*`",  "\"# * #\""),
  ("operator/",  "`/`",  "\"# / #\""),
  ("operator%",  "`mod`","\"# %% #\""),
  ("operator==", "`==`", "\"# == #\""),
  ("operator!=", "`!=`", "\"# != #\""),
  ("operator<",  "`<`",  "\"# < #\""),
  ("operator<=", "`<=`", "\"# <= #\""),
  ("operator>",  "`>`",  "\"# > #\""),
  ("operator>=", "`>=`", "\"# >= #\""),
  ("operator[]", "`[]`", "\"#[#]\""),
  ("operator()", "`()`", "\"#(@)\""),
  ("operator<<", "`shl`","\"# << #\""),
  ("operator>>", "`shr`","\"# >> #\""),
  ("operator&",  "`and`","\"# & #\""),
  ("operator|",  "`or`", "\"# | #\""),
  ("operator^",  "`xor`","\"# ^ #\""),
  ("operator~",  "`not`","\"~#\""),
  ("operator!",  "`not`","\"!#\""),
  ("operator++", "inc",  "\"++#\""),
  ("operator--", "dec",  "\"--#\""),
  ("operator+=", "`+=`", "\"# += #\""),
  ("operator-=", "`-=`", "\"# -= #\""),
  ("operator*=", "`*=`", "\"# *= #\""),
  ("operator/=", "`/=`", "\"# /= #\""),
  ("operator new",    "new",    ""),
  ("operator delete", "delete", ""),
]

proc operatorName*(name: system.string): system.string =
  for entry in OperatorPatterns:
    if entry[0] == name:
      return entry[1]
  result = name


proc addSrc*(conv: var Converter, text: string): astTF.Location =
  let start = conv.ast.data.modules[conv.module].source.len.uint64
  conv.ast.data.modules[conv.module].source.add text
  result = astTF.Location(start: start, `end`: start + text.len.uint64)


proc addName*(conv: var Converter, text: string): astTF.Identifier =
  result = astTF.Identifier(location: conv.addSrc(text))


proc addRenamed*(conv: var Converter, kind: LabelKind, cName: system.string): astTF.Identifier =
  let renamed = conv.renamer(kind, cName)
  let sanitized = conv.sanitizer(renamed)
  result = conv.addName(sanitized)


proc linkAfter*(conv: var Converter, previousId: astTF.Id, nextId: astTF.Id) =
  var previous = conv.ast.data.statements[previousId]
  case previous.kind
  of astTF.sVariable    : previous.variable.next    = some(nextId)
  of astTF.sType        : previous.`type`.next      = some(nextId)
  of astTF.sAlias       : previous.alias.next       = some(nextId)
  of astTF.sProcedure   : previous.procedure.next   = some(nextId)
  of astTF.sComment     : previous.comment.next     = some(nextId)
  of astTF.sImport      : previous.`import`.next    = some(nextId)
  of astTF.sPassthrough : previous.passthrough.next = some(nextId)
  of astTF.sPragma      : previous.pragma.next      = some(nextId)
  of astTF.sExpression  : previous.expression.next  = some(nextId)
  of astTF.sKeyword     : previous.keyword.next     = some(nextId)
  of astTF.sBranch      : previous.branch.next      = some(nextId)
  conv.ast.data.statements[previousId] = previous

proc add_statement_chained*(conv: var Converter, statement: astTF.Statement): astTF.Id {.discardable.} =
  let stmtId = conv.ast.add_statement(statement)

  case statement.kind
  of astTF.sType:
    if conv.lastTypeStmt.isSome: conv.linkAfter(conv.lastTypeStmt.get, stmtId)
    if conv.firstTypeStmt.isNone: conv.firstTypeStmt = some(stmtId)
    conv.lastTypeStmt = some(stmtId)
  of astTF.sAlias:
    if conv.lastAliasStmt.isSome: conv.linkAfter(conv.lastAliasStmt.get, stmtId)
    if conv.firstAliasStmt.isNone: conv.firstAliasStmt = some(stmtId)
    conv.lastAliasStmt = some(stmtId)
  else:
    if conv.lastOtherStmt.isSome: conv.linkAfter(conv.lastOtherStmt.get, stmtId)
    if conv.firstOtherStmt.isNone: conv.firstOtherStmt = some(stmtId)
    conv.lastOtherStmt = some(stmtId)

  result = stmtId

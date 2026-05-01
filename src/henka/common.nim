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

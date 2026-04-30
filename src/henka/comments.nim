# @deps std
from std/strutils import join, startsWith, endsWith, replace, strip, split
# @deps slate
import slate/ast as astTF
# @deps henka
import ./clang
import ./common


proc strip_doxygen (text :system.string) :system.string=
  result = text
  for cmd in ["\\c ", "\\p ", "\\a ", "\\e ", "\\b "]:
    result = result.replace(cmd, "")


proc strip_block_comment (raw :system.string) :system.string=
  var lines = raw.split("\n")
  var cleaned :seq[system.string]= @[]
  for line in lines:
    var stripped = line.strip()
    if stripped.startsWith("* "): stripped = stripped[2..^1]
    elif stripped == "*": stripped = ""
    cleaned.add stripped
  result = cleaned.join("\n")
  while result.len > 0 and result[^1] == '\n': result = result[0..^2]


proc add_comment *(conv :var Converter; text :string; isDoc :bool) :astTF.Id=
  let kindStr   = if isDoc: "///" else: "//"
  let kindIdent = conv.addName(kindStr)
  let textLoc   = conv.addSrc(text)
  result = conv.ast.add_comment(Comment(kind: kindIdent, text: textLoc))


proc add_comment *(conv :var Converter; cursor :CXCursor) :Option[astTF.Id]=
  let raw = cursor.rawComment
  if raw.len == 0: return none(astTF.Id)
  let isDoc = raw.startsWith("///") or raw.startsWith("/**")
  var text = raw
  if   text.startsWith("///")                         : text = text[3..^1].strip(leading=true, trailing=false)
  elif text.startsWith("//")                          : text = text[2..^1].strip(leading=true, trailing=false)
  elif text.startsWith("/**") and text.endsWith("*/") : text = strip_block_comment(text[3..^3])
  elif text.startsWith("/*")  and text.endsWith("*/") : text = strip_block_comment(text[2..^3])
  if text.len > 0 and text[^1] == '\n': text = text[0..^2]
  text = strip_doxygen(text)
  let commentId = conv.add_comment(text, isDoc)
  return some(commentId)


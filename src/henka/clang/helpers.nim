# @deps std
from std/os import lastPathPart
from std/strutils import startsWith
# @deps clang
when defined(clang_selfhosted):
  import ./clang/api
else:
  import ./clang/minimal as api


# Parse option constants  (FIX: Remove. Should not be needed)
when not declared(CXTranslationUnit_None):
  const CXTranslationUnit_None*                        : cuint = 0x0
  const CXTranslationUnit_DetailedPreprocessingRecord* : cuint = 0x01
  const CXTranslationUnit_SkipFunctionBodies*          : cuint = 0x40
  const CXTranslationUnit_SingleFileParse*             : cuint = 0x400


proc spelling*(cursor: CXCursor): string =
  let cxstr = clang_getCursorSpelling(cursor)
  result = $clang_getCString(cxstr)
  clang_disposeString(cxstr)


proc typeSpelling*(typ: CXType): string =
  let cxstr = clang_getTypeSpelling(typ)
  result = $clang_getCString(cxstr)
  clang_disposeString(cxstr)


proc cursorFileName*(cursor: CXCursor): system.string =
  let loc = clang_getCursorLocation(cursor)
  var file: pointer = nil
  var line, column, offset: cuint

  clang_getFileLocation(loc, addr file, addr line, addr column, addr offset)

  if file.isNil:
    return ""

  let fileStr = clang_getFileName(file)
  let raw = clang_getCString(fileStr)

  if raw.isNil:
    clang_disposeString(fileStr)
    return ""

  result = $raw
  clang_disposeString(fileStr)


proc isFromFile*(cursor: CXCursor; headerFile: string): bool =
  let fileName = cursor.cursorFileName
  if fileName.len == 0:
    return false

  return fileName.lastPathPart == headerFile.lastPathPart


proc isFromDirectory*(cursor: CXCursor; directory: string): bool =
  let fileName = cursor.cursorFileName
  if fileName.len == 0:
    return false

  return fileName.startsWith(directory)


proc rawComment*(cursor: CXCursor): string =
  let cxstr = clang_Cursor_getRawCommentText(cursor)
  let raw = clang_getCString(cxstr)
  result = if raw.isNil: "" else: $raw
  clang_disposeString(cxstr)

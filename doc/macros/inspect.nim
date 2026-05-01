import ../../src/henka/clang

let index = clang_createIndex(0, 0)
let unit = clang_parseTranslationUnit(index, "doc/macros/real.h".cstring, nil, 0.cint, nil, 0.cuint,
  (CXTranslationUnit_DetailedPreprocessingRecord or CXTranslationUnit_SkipFunctionBodies).cuint)

var globalTU: CXTranslationUnit = unit

proc inspect(cursor: CXCursor, parent: CXCursor, data: pointer): cint {.cdecl.} =
  let kind = clang_getCursorKind(cursor)
  if kind != CXCursor_MacroDefinition:
    return CXChildVisit_Continue.cint

  let name = cursor.spelling
  let isFunctionLike = clang_Cursor_isMacroFunctionLike(cursor) != 0

  echo "=== ", name, if isFunctionLike: " (function-like)" else: " (object-like)", " ==="

  let extent = clang_getCursorExtent(cursor)
  var tokens: ptr CXToken = nil
  var numTokens: cuint = 0
  clang_tokenize(globalTU, extent, addr tokens, addr numTokens)

  echo "  tokens (", numTokens, "):"
  for idx in 0..<numTokens:
    let token = cast[ptr CXToken](cast[uint](tokens) + idx.uint * sizeof(CXToken).uint)[]
    let spelling = clang_getTokenSpelling(globalTU, token)
    let text = $clang_getCString(spelling)
    clang_disposeString(spelling)
    let prefix = if idx == 0: "  [name] " else: "  [" & $idx & "]    "
    echo prefix, repr(text)

  if not tokens.isNil:
    clang_disposeTokens(globalTU, tokens, numTokens)

  let evalResult = clang_Cursor_Evaluate(cursor)
  if not evalResult.isNil:
    let evalKind = clang_EvalResult_getKind(evalResult)
    case evalKind
    of CXEval_Int:
      echo "  eval: int = ", clang_EvalResult_getAsLongLong(evalResult)
    of CXEval_Float:
      echo "  eval: float = ", clang_EvalResult_getAsDouble(evalResult)
    else:
      echo "  eval: kind=", evalKind
    clang_EvalResult_dispose(evalResult)
  else:
    echo "  eval: (none)"

  echo ""
  return CXChildVisit_Continue.cint

let root = clang_getTranslationUnitCursor(unit)
discard clang_visitChildren(root, inspect, nil)

clang_disposeTranslationUnit(unit)
clang_disposeIndex(index)

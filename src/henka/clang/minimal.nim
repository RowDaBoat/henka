# @fileoverview
#  Manually written libclang bindings
#  Minimal features to support selfhosting libclang bindings with henka
#_______________________________________
const libclang {.strdefine.} =
  when(defined(windows)): "libclang.dll"
  elif(defined(macosx)):   gorgeEx("xcode-select -p").output & "/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib"
  else:                   "libclang.so"

type CXIndex*             = pointer
type CXTranslationUnit*   = pointer
type CXCursor *{.bycopy.} = object
  kind*:  cint
  xdata*: cint
  data*:  array[3, pointer]
type CXString *{.bycopy.} = object
  data*:         pointer
  privateFlags*: cuint
type CXType *{.bycopy.} = object
  kind*: cint
  data*: array[2, pointer]

proc clang_createIndex*(a: cint, b: cint): CXIndex {.importc, dynlib: libclang, cdecl.}
proc clang_parseTranslationUnit*(index: CXIndex, src: cstring, args: ptr cstring, argc: cint, unsaved: pointer, nunsaved: cuint, opts: cuint): CXTranslationUnit {.importc, dynlib: libclang, cdecl.}
proc clang_getTranslationUnitCursor*(unit: CXTranslationUnit): CXCursor {.importc, dynlib: libclang, cdecl.}
proc clang_getCursorKind*(cursor: CXCursor): cint {.importc, dynlib: libclang, cdecl.}
proc clang_getCursorSpelling*(cursor: CXCursor): CXString {.importc, dynlib: libclang, cdecl.}
proc clang_getCString*(str: CXString): cstring {.importc, dynlib: libclang, cdecl.}
proc clang_disposeString*(str: CXString) {.importc, dynlib: libclang, cdecl.}
proc clang_getCursorType*(cursor: CXCursor): CXType {.importc, dynlib: libclang, cdecl.}
proc clang_getTypeSpelling*(typ: CXType): CXString {.importc, dynlib: libclang, cdecl.}
proc clang_getTypedefDeclUnderlyingType*(cursor: CXCursor): CXType {.importc, dynlib: libclang, cdecl.}
proc clang_getResultType*(typ: CXType): CXType {.importc, dynlib: libclang, cdecl.}
proc clang_getNumArgTypes*(typ: CXType): cint {.importc, dynlib: libclang, cdecl.}
proc clang_getArgType*(typ: CXType, index: cuint): CXType {.importc, dynlib: libclang, cdecl.}
proc clang_getEnumConstantDeclValue*(cursor: CXCursor): clonglong {.importc, dynlib: libclang, cdecl.}
proc clang_Cursor_getNumArguments*(cursor: CXCursor): cint {.importc, dynlib: libclang, cdecl.}
proc clang_Cursor_getArgument*(cursor: CXCursor, index: cuint): CXCursor {.importc, dynlib: libclang, cdecl.}
proc clang_getPointeeType*(typ: CXType): CXType {.importc, dynlib: libclang, cdecl.}
proc clang_getNumElements*(typ: CXType): clonglong {.importc, dynlib: libclang, cdecl.}
proc clang_getArrayElementType*(typ: CXType): CXType {.importc, dynlib: libclang, cdecl.}
proc clang_Cursor_getRawCommentText*(cursor: CXCursor): CXString {.importc, dynlib: libclang, cdecl.}
proc clang_Cursor_getBriefCommentText*(cursor: CXCursor): CXString {.importc, dynlib: libclang, cdecl.}
proc clang_disposeIndex*(index: CXIndex) {.importc, dynlib: libclang, cdecl.}
proc clang_disposeTranslationUnit*(unit: CXTranslationUnit) {.importc, dynlib: libclang, cdecl.}
proc clang_Cursor_isMacroFunctionLike*(cursor: CXCursor): cuint {.importc, dynlib: libclang, cdecl.}
proc clang_Cursor_isVariadic*(cursor: CXCursor): cuint {.importc, dynlib: libclang, cdecl.}
# C++ query procs
proc clang_CXXMethod_isStatic*(cursor: CXCursor): cuint {.importc, dynlib: libclang, cdecl.}
proc clang_CXXMethod_isConst*(cursor: CXCursor): cuint {.importc, dynlib: libclang, cdecl.}
proc clang_CXXMethod_isVirtual*(cursor: CXCursor): cuint {.importc, dynlib: libclang, cdecl.}
proc clang_CXXMethod_isPureVirtual*(cursor: CXCursor): cuint {.importc, dynlib: libclang, cdecl.}
proc clang_EnumDecl_isScoped*(cursor: CXCursor): cuint {.importc, dynlib: libclang, cdecl.}
proc clang_getCursorReferenced*(cursor: CXCursor): CXCursor {.importc, dynlib: libclang, cdecl.}
proc clang_getCursorSemanticParent*(cursor: CXCursor): CXCursor {.importc, dynlib: libclang, cdecl.}
proc clang_getSpecializedCursorTemplate*(cursor: CXCursor): CXCursor {.importc, dynlib: libclang, cdecl.}
proc clang_getNumTemplateArguments*(cursor: CXCursor): cint {.importc, dynlib: libclang, cdecl.}
proc clang_getCXXAccessSpecifier*(cursor: CXCursor): cint {.importc, dynlib: libclang, cdecl.}
proc clang_isCursorDefinition*(cursor: CXCursor): cuint {.importc, dynlib: libclang, cdecl.}
proc clang_getCanonicalType*(typ: CXType): CXType {.importc, dynlib: libclang, cdecl.}
proc clang_Type_getNumTemplateArguments*(typ: CXType): cint {.importc, dynlib: libclang, cdecl.}
proc clang_Type_getTemplateArgumentAsType*(typ: CXType, index: cuint): CXType {.importc, dynlib: libclang, cdecl.}
const CX_CXXPublic*:    cint = 1
const CX_CXXProtected*: cint = 2
const CX_CXXPrivate*:   cint = 3

type CXEvalResult* = pointer
proc clang_Cursor_Evaluate*(cursor: CXCursor): CXEvalResult {.importc, dynlib: libclang, cdecl.}
proc clang_EvalResult_getKind*(result: CXEvalResult): cint {.importc, dynlib: libclang, cdecl.}
proc clang_EvalResult_getAsInt*(result: CXEvalResult): cint {.importc, dynlib: libclang, cdecl.}
proc clang_EvalResult_getAsLongLong*(result: CXEvalResult): clonglong {.importc, dynlib: libclang, cdecl.}
proc clang_EvalResult_getAsUnsigned*(result: CXEvalResult): culonglong {.importc, dynlib: libclang, cdecl.}
proc clang_EvalResult_getAsDouble*(result: CXEvalResult): cdouble {.importc, dynlib: libclang, cdecl.}
proc clang_EvalResult_dispose*(result: CXEvalResult) {.importc, dynlib: libclang, cdecl.}

const CXEval_Int*:       cint = 1
const CXEval_Float*:     cint = 2
const CXEval_UnExposed*: cint = 0
type CXSourceLocation *{.bycopy.} = object
  ptr_data*: array[2, pointer]
  int_data*: cuint

proc clang_getCursorLocation*(cursor: CXCursor): CXSourceLocation {.importc, dynlib: libclang, cdecl.}
proc clang_getFileLocation*(location: CXSourceLocation, file: ptr pointer, line: ptr cuint, column: ptr cuint, offset: ptr cuint) {.importc, dynlib: libclang, cdecl.}
proc clang_getFileName*(file: pointer): CXString {.importc, dynlib: libclang, cdecl.}

type CXSourceRange *{.bycopy.} = object
  ptr_data*:       array[2, pointer]
  begin_int_data*: cuint
  end_int_data*:   cuint

type CXToken *{.bycopy.} = object
  int_data*: array[4, cuint]
  ptr_data*: pointer

proc clang_getCursorExtent*(cursor: CXCursor): CXSourceRange {.importc, dynlib: libclang, cdecl.}
proc clang_tokenize*(tu: CXTranslationUnit, range: CXSourceRange, tokens: ptr ptr CXToken, numTokens: ptr cuint) {.importc, dynlib: libclang, cdecl.}
proc clang_disposeTokens*(tu: CXTranslationUnit, tokens: ptr CXToken, numTokens: cuint) {.importc, dynlib: libclang, cdecl.}
proc clang_getTokenSpelling*(tu: CXTranslationUnit, token: CXToken): CXString {.importc, dynlib: libclang, cdecl.}

type CXCursorVisitor* = proc(cursor: CXCursor, parent: CXCursor, clientData: pointer): cint {.cdecl.}
proc clang_visitChildren*(parent: CXCursor, visitor: CXCursorVisitor, clientData: pointer): cuint {.importc, dynlib: libclang, cdecl.}

# Translation unit parse options
const CXTranslationUnit_None*                        : cuint = 0x0
const CXTranslationUnit_DetailedPreprocessingRecord* : cuint = 0x01
const CXTranslationUnit_Incomplete*                  : cuint = 0x02
const CXTranslationUnit_SkipFunctionBodies*          : cuint = 0x40
const CXTranslationUnit_SingleFileParse*             : cuint = 0x400
const CXTranslationUnit_KeepGoing*                   : cuint = 0x200
# Visit Controls
const CXChildVisit_Continue*          : cint = 1
const CXChildVisit_Recurse*           : cint = 2
# C cursor kinds
const CXCursor_StructDecl*            : cint = 2
const CXCursor_EnumDecl*              : cint = 5
const CXCursor_FieldDecl*             : cint = 6
const CXCursor_EnumConstantDecl*      : cint = 7
const CXCursor_FunctionDecl*          : cint = 8
const CXCursor_VarDecl*               : cint = 9
const CXCursor_ParmDecl*              : cint = 10
const CXCursor_TypedefDecl*           : cint = 20
const CXCursor_MacroDefinition*       : cint = 501
# C++ cursor kinds
const CXCursor_UnionDecl*             : cint = 3
const CXCursor_ClassDecl*             : cint = 4
const CXCursor_CXXMethod*             : cint = 21
const CXCursor_Namespace*             : cint = 22
const CXCursor_Constructor*           : cint = 24
const CXCursor_Destructor*            : cint = 25
const CXCursor_ConversionFunction*    : cint = 26
const CXCursor_TemplateTypeParameter* : cint = 27
const CXCursor_FunctionTemplate*      : cint = 30
const CXCursor_ClassTemplate*         : cint = 31
const CXCursor_CXXAccessSpecifier*    : cint = 39
const CXCursor_CXXBaseSpecifier*      : cint = 44
const CXCursor_TypeAliasDecl*         : cint = 36
const CXCursor_UsingDeclaration*      : cint = 35
const CXType_Unexposed*               : cint = 1
const CXType_Void*                    : cint = 2
const CXType_Bool*                    : cint = 3
const CXType_UChar*                   : cint = 5
const CXType_Char16*                  : cint = 6
const CXType_Char32*                  : cint = 7
const CXType_UShort*                  : cint = 8
const CXType_UInt*                    : cint = 9
const CXType_ULong*                   : cint = 10
const CXType_ULongLong*               : cint = 11
const CXType_Char_S*                  : cint = 13
const CXType_SChar*                   : cint = 14
const CXType_WChar*                   : cint = 15
const CXType_Short*                   : cint = 16
const CXType_Int*                     : cint = 17
const CXType_Long*                    : cint = 18
const CXType_LongLong*                : cint = 19
const CXType_Float*                   : cint = 21
const CXType_Double*                  : cint = 22
const CXType_LongDouble*              : cint = 23
const CXType_Pointer*                 : cint = 101
const CXType_LValueReference*         : cint = 103
const CXType_RValueReference*         : cint = 104
const CXType_Record*                  : cint = 105
const CXType_Typedef*                 : cint = 107
const CXType_FunctionProto*           : cint = 111
const CXType_FunctionNoProto*         : cint = 110
const CXType_ConstantArray*           : cint = 112
const CXType_MemberPointer*           : cint = 117
const CXType_IncompleteArray*         : cint = 114
const CXType_Auto*                    : cint = 118
const CXType_Elaborated*              : cint = 119


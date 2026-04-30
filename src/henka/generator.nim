# @deps std
from std/os import paramStr, paramCount, splitFile, changeFileExt
from std/strutils import join, startsWith
# @deps slate
import slate/ast as astTF
import slate
# #deps henka
import ./clang
import ./common
import ./pragmas
import ./statements
import ./cpp
import ./callbacks


#_______________________________________
# @section Generator: Visitor Entry Point
#_____________________________
proc visitor (cursor :CXCursor; parent :CXCursor; clientData :pointer) :cint {.cdecl.}=
  var conv = cast[ptr Converter](clientData)
  let kind = clang_getCursorKind(cursor)
  let accepted =
    if conv[].includeDir.len > 0 : cursor.isFromDirectory(conv[].includeDir)
    else                         : cursor.isFromFile(conv[].headerFile)
  if not accepted: return CXChildVisit_Continue.cint
  let name = cursor.spelling
  let filterKind = case kind
    of CXCursor_TypedefDecl,
       CXCursor_TypeAliasDecl    : Typedef
    of CXCursor_StructDecl       : StructType
    of CXCursor_EnumDecl         : EnumType
    of CXCursor_FunctionDecl,
       CXCursor_FunctionTemplate : Proc
    of CXCursor_VarDecl          : Variable
    of CXCursor_MacroDefinition  : Constant
    of CXCursor_ClassDecl,
       CXCursor_ClassTemplate    : StructType
    else                         : Proc
  if name.len > 0 and kind != CXCursor_Namespace and not conv[].symbolFilter(filterKind, name):
    return CXChildVisit_Continue.cint
  if name.len > 0 and kind != CXCursor_Namespace:
    let override = conv[].symbolOverride(filterKind, name)
    if override.isSome:
      let passthroughLoc = conv[].addSrc(override.get)
      conv[].add_statement_chained(Statement(kind: astTF.sPassthrough, passthrough: StatementPassthrough(location: passthroughLoc)))
      return CXChildVisit_Continue.cint
  if name.len > 0 and kind != CXCursor_Namespace and kind != CXCursor_MacroDefinition and kind != CXCursor_FunctionDecl and kind != CXCursor_CXXMethod:
    if name in conv[].seenSymbols: return CXChildVisit_Continue.cint
    conv[].seenSymbols.incl name
  case kind
  of CXCursor_TypedefDecl      : return conv[].toAlias(cursor, name)
  of CXCursor_StructDecl       : return conv[].toObject(cursor, name)
  of CXCursor_EnumDecl         : return conv[].toEnum(cursor, name)
  of CXCursor_FunctionDecl     : return conv[].toProcedure(cursor, name)
  of CXCursor_VarDecl          : return conv[].toVariable(cursor, name)
  of CXCursor_MacroDefinition  : return conv[].toMacro(cursor, name)
  of CXCursor_ClassDecl        : return conv[].toClass(cursor, name)
  of CXCursor_ClassTemplate    : return conv[].toClassTemplate(cursor, name)
  of CXCursor_FunctionTemplate : return conv[].toFunctionTemplate(cursor, name)
  of CXCursor_Namespace        : return CXChildVisit_Recurse.cint
  of CXCursor_TypeAliasDecl    : return conv[].toAlias(cursor, name)
  else                         : return CXChildVisit_Continue.cint


#_______________________________________
# @section Generator: Internal Helpers
#_____________________________
proc failed_module (inputFile :system.string; clangArgs :seq[system.string]; isCpp :bool; includeDir :system.string) :slate.codegen.Module=
  var diagnostic = "# Failed to parse: " & inputFile & "\n"
  diagnostic.add "# isCpp: " & $isCpp & "\n"
  if includeDir.len > 0:
    diagnostic.add "# includeDir: " & includeDir & "\n"
  if clangArgs.len > 0:
    diagnostic.add "# clangArgs: " & clangArgs.join(" ") & "\n"
  diagnostic.add "# Ensure the file exists and all include paths are correct.\n"
  result = slate.codegen.Module(path: inputFile, definitions: diagnostic)


#_______________________________________
# @section Generator: Entry Point
#_____________________________
proc generate *(
    inputFiles        : seq[system.string];
    clangArgs         : seq[system.string] = @[];
    isCpp             : bool               = false;
    includeDir        : system.string      = "";
    renamer           : Renamer            = defaultRenamer;
    constructorName   : NamePattern        = defaultConstructorName;
    destructorName    : NamePattern        = defaultDestructorName;
    symbolFilter      : SymbolFilter       = defaultSymbolFilter;
    symbolOverride    : SymbolOverride     = defaultSymbolOverride;
    unnamedFieldNamer : UnnamedFieldNamer  = defaultUnnamedFieldNamer;
    typeMapper        : TypeMapper         = defaultTypeMapper;
    singleFileParse   : bool               = true;
    linkMode          : LinkMode           = LinkMode.header;
    dynlibName        : system.string      = "";
    dynlibPath        : system.string      = "";
  ) :Output=
  result = Output(modules: @[])
  if inputFiles.len == 0: return
  let index = clang_createIndex(0, 0)
  defer: clang_disposeIndex(index)

  var conv = Converter(
    ast               : astTF.Ast(root: 0, data: astTF.AstData(modules: @[])),
    headerFile        : "",
    module            : 0,
    tu                : nil,
    seenStructs       : initHashSet[system.string](),
    seenEnums         : initHashSet[system.string](),
    seenSymbols       : initHashSet[system.string](),
    renamer           : renamer,
    isCpp             : isCpp,
    includeDir        : includeDir,
    constructorName   : constructorName,
    destructorName    : destructorName,
    symbolFilter      : symbolFilter,
    symbolOverride    : symbolOverride,
    unnamedFieldNamer : unnamedFieldNamer,
    typeMapper        : typeMapper,
    linkMode          : linkMode,
    dynlibName        : dynlibName,
    dynlibPath        : dynlibPath)

  for fileIdx, inputFile in inputFiles:
    echo "[", fileIdx + 1, "/", inputFiles.len, "] ", inputFile
    var args :seq[cstring]= @[]
    if isCpp: args.add "-xc++"
    for extra in clangArgs: args.add extra.cstring
    let argsPtr = if args.len > 0: addr args[0] else: nil
    let argsLen = args.len.cint

    var opts = CXTranslationUnit_DetailedPreprocessingRecord.cuint or CXTranslationUnit_SkipFunctionBodies.cuint
    if singleFileParse: opts = opts or CXTranslationUnit_SingleFileParse.cuint
    let unit = clang_parseTranslationUnit(index, inputFile.cstring, argsPtr, argsLen, nil, 0, opts)
    if unit.isNil:
      result.modules.add failed_module(inputFile, clangArgs, isCpp, includeDir)
      continue

    let moduleIdx = conv.ast.data.modules.len
    conv.ast.data.modules.add astTF.Module(path: inputFile, source: "")
    conv.headerFile = inputFile
    conv.tu = unit
    conv.module = astTF.Id(moduleIdx)
    conv.lastStatement = none(astTF.Id)
    if conv.linkMode == LinkMode.dynlib and moduleIdx == 0 and conv.dynlibName.len > 0:
      let nameIdent  = conv.addName(conv.dynlibName)
      let valueLoc   = conv.addSrc("\"" & conv.dynlibPath & "\"")
      let valueExpr  = conv.ast.add_expression(Expression(kind: astTF.eLiteral, literal: ExpressionLiteral(kind: LiteralKind.string, value: valueLoc)))
      let pragmaId   = conv.addPragma("strdefine")
      let bindingId  = conv.ast.add_binding(Binding(name: some(nameIdent), value: some(valueExpr), pragmas: some(pragmaId)))
      conv.add_statement_chained(Statement(kind: astTF.sVariable, variable: StatementVariable(id: bindingId)))

    let rootCursor = clang_getTranslationUnitCursor(unit)
    discard clang_visitChildren(rootCursor, visitor, addr conv)
    clang_disposeTranslationUnit(unit)

  # Render each module
  var nimOut = Output(modules: @[])
  for idx in 0..<conv.ast.data.modules.len:
    nimOut.modules.add output.Module(path: conv.ast.data.modules[idx].path)

  for idx in 0..<conv.ast.data.modules.len:
    let moduleBody = conv.ast.data.modules[idx].body
    if moduleBody.isSome:
      conv.ast.statement_list(astTF.Id(idx), moduleBody.get, Target.definition, nimOut)

  for idx in 0..<conv.ast.data.modules.len:
    result.modules.add output.Module(
      path        : conv.ast.data.modules[idx].path,
      definitions : nimOut.modules[idx].definitions)


#_______________________________________
# @section Generator: Single File Overload
#_____________________________
proc generate *(
    inputFile         : system.string;
    clangArgs         : seq[system.string] = @[];
    isCpp             : bool               = false;
    includeDir        : system.string      = "";
    renamer           : Renamer            = defaultRenamer;
    constructorName   : NamePattern        = defaultConstructorName;
    destructorName    : NamePattern        = defaultDestructorName;
    symbolFilter      : SymbolFilter       = defaultSymbolFilter;
    symbolOverride    : SymbolOverride     = defaultSymbolOverride;
    unnamedFieldNamer : UnnamedFieldNamer  = defaultUnnamedFieldNamer;
    typeMapper        : TypeMapper         = defaultTypeMapper;
    linkMode          : LinkMode           = LinkMode.header;
    dynlibName        : system.string      = "";
    dynlibPath        : system.string      = "";
  ) :system.string=
  let generated = generate(@[inputFile], clangArgs, isCpp, includeDir,
    renamer, constructorName, destructorName, symbolFilter, symbolOverride,
    unnamedFieldNamer, typeMapper, singleFileParse = false,
    linkMode = linkMode, dynlibName = dynlibName, dynlibPath = dynlibPath)
  if generated.modules.len > 0: result = generated.modules[0].definitions
  else: result = ""


#_______________________________________
# @section CLI Entry Point
#_____________________________
proc run* =
  if paramCount() < 1:
    echo "Usage: generator [--cpp] [--include-dir=path] [-Ipath] [-Ddefine] [-std=c++17] <header>"
    quit(1)

  var inputFile = ""
  var forceCpp = false
  var includeDir = ""
  var extraArgs :seq[system.string]= @[]
  for idx in 1..paramCount():
    let arg = paramStr(idx)
    if arg == "--cpp": forceCpp = true
    elif arg.startsWith("--include-dir="): includeDir = arg[len("--include-dir=")..^1]
    elif arg.startsWith("-I") or arg.startsWith("-D") or arg.startsWith("-std="): extraArgs.add arg
    else: inputFile = arg

  if inputFile.len == 0:
    echo "Usage: poc_ext [--cpp] [--include-dir=path] [-Ipath] [-Ddefine] [-std=c++17] <header>"
    quit(1)

  let isCpp = forceCpp or inputFile.splitFile.ext in [".hpp", ".hxx", ".h++", ".hh"]
  let output = generate(inputFile, extraArgs, isCpp, includeDir)
  if output.len > 0:
    echo output
    let outFile = inputFile.changeFileExt(".nim")
    outFile.writeFile(output)
    echo "\nWrote: ", outFile
#___________________
when isMainModule: run()


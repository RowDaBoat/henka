# @description
#  henka bindings generator for libclang, using libclang+henka
#  Usage:
#    nim r --path:<slate> --path:<astTF> path/to/thisfile.nim
#_____________________________________________________________________
# @deps std
from std/os import walkDir, pcFile, splitFile, `/`, createDir, parentDir
from std/strutils import endsWith
# @deps henka
import ../../henka

const libclang {.strdefine.} =
  when(defined(windows)): "libclang.dll"
  elif(defined(macosx)):   gorgeEx("xcode-select -p").output & "/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib"
  else:                   "libclang.so"

const libclangInclude   {.strdefine.} = "/"/"usr"/"include"
const libclangHeaderDir {.strdefine.} = libclangInclude/"clang-c"
const outputFile                      = currentSourcePath().parentDir()/"api.nim"

proc filter (kind :LabelKind; name :string) :bool=
  result = name notin [
    "LLVM_CLANG_C_EXTERN_C_BEGIN", "LLVM_CLANG_C_EXTERN_C_END",
    "LLVM_CLANG_C_STRICT_PROTOTYPES_BEGIN", "LLVM_CLANG_C_STRICT_PROTOTYPES_END",
    "CINDEX_LINKAGE", "CINDEX_DEPRECATED",
    "CINDEX_VERSION", "CINDEX_VERSION_STRING",
  ]

proc typemap (name :string) :Option[string]=
  result = case name
    of "time_t": some("clong")
    else:        defaultTypeMapper(name)

when isMainModule:
  let hdr = libclangHeaderDir
  let inputFiles = @[
    hdr / "Platform.h",
    hdr / "ExternC.h",
    hdr / "CXErrorCode.h",
    hdr / "CXString.h",
    hdr / "CXFile.h",
    hdr / "CXSourceLocation.h",
    hdr / "CXDiagnostic.h",
    hdr / "Index.h",
    hdr / "CXCompilationDatabase.h",
    hdr / "BuildSystem.h",
    hdr / "FatalErrorHandler.h",
    hdr / "Documentation.h",
    hdr / "Rewrite.h",
  ]

  echo "Generating libclang bindings for ", inputFiles.len, " headers..."
  let output = generate(
    inputFiles      = inputFiles,
    clangArgs       = @["-I" & libclangInclude],
    symbolFilter    = filter,
    typeMapper      = typemap,
    singleFileParse = false,
    linkMode        = LinkMode.dynlib,
    dynlibName      = "libclang",
    dynlibPath      = libclang
  )

  var combined = ""
  for module in output.modules:
    if module.definitions.len > 0:
      combined.add module.definitions

      if not combined.endsWith("\n"):
        combined.add "\n"

  outputFile.writeFile(combined)
  echo "Wrote: ", outputFile


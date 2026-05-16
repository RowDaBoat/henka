import std/[unittest, os, osproc, strformat, strtabs, strutils]
import ../src/henka


proc nim(action: string, file: string, flags: string = ""): bool =
  let (output, exitCode) = execCmdEx(&"nim {action} {flags} {quoteShell(file)}")

  if exitCode != 0:
    echo output

  result = exitCode == 0


proc clang(file: string, output: string, args: varargs[string]): bool =
  let argsSeq = @args.join(" ")
  let cmd = &"clang {argsSeq} -o {quoteShell(output)} {quoteShell(file)}"
  let (output, exitCode) = execCmdEx(cmd)

  if exitCode != 0:
    echo output

  result = exitCode == 0


proc toDylib(path: string): string =
  let (dir, name, _) = splitFile(path)
  when defined(windows): dir / (name & ".dll")
  elif defined(macosx):  dir / ("lib" & name & ".dylib")
  else:                  dir / ("lib" & name & ".so")


const bindings = "bindings.nim"
const target = "target.nim"
const dynlib = "dynlib.c"
const baseDir = currentSourcePath().parentDir()

const check = "check"
const run = "r"


type Feature = object
  testType: string
  name: string
  enumMode: EnumMode
  enumOptions: EnumOptions
  linkMode: LinkMode
  dynlibName: string
  dynlibPath: string


proc feature(
  testType: string,
  name: string,
  enumMode: EnumMode = EnumMode.Default,
  enumOptions: EnumOptions = EnumOptions.Default,
  linkMode: LinkMode = LinkMode.header,
  dynlibName: string = "",
  dynlibPath: string = "",
): Feature =
  Feature(
    testType: testType,
    name: name,
    enumMode: enumMode,
    enumOptions: enumOptions,
    linkMode: linkMode,
    dynlibName: dynLibName,
    dynlibPath: dynLibPath,
  )

const c = "c"
const cHeader = "header.h"
const cFeatures = [
  feature(check, "builtin_types"),
  feature(run,   "dynamic_libs", linkMode = LinkMode.dynlib, dynlibName = "dynlib", dynlibPath = "dynlib".toDylib),
  feature(check, "empty_files"),
  feature(run,   "macros"),
  feature(run,   "enums_to_pure"),
  feature(run,   "enums_to_cint",     EnumMode.Cint,  EnumOptions.Default),
  feature(run,   "enums_to_const",    EnumMode.Const, EnumOptions.Default),
  feature(run,   "enums_to_distinct", EnumMode.Cint,  {EnumOption.Distinct}),
  feature(run,   "enums_to_enums"),
  feature(run,   "enums_holes"),
  feature(run,   "enums_negative"),
  feature(run,   "enums_bitflags"),
  feature(run,   "enums_typedef"),
  feature(run,   "enums_anonymous"),
  feature(run,   "enums_sentinel"),
  feature(run,   "enums_in_signatures"),
  feature(run,   "enums_mixed"),
  feature(check, "structs"),
  feature(check, "inner_structs"),
  feature(check, "unions"),
  feature(check, "inner_unions"),
  feature(check, "pointers"),
  feature(check, "function_pointers"),
  feature(check, "typedefs"),
  feature(check, "forward_declarations"),
  feature(check, "variables"),
  feature(check, "functions"),
  feature(check, "passthrough_pragmas"),
  feature(check, "respect_ordering"),
  feature(check, "externc"),
  feature(check, "not_regress_on_bugs"),
]


suite "Henka C should support":
  for f in cFeatures:
    test f.name.replace("_", " "):
      let workdir = baseDir/c/f.name
      let dynlibPath = baseDir/c/f.name/dynlib
      var flags = ""

      if fileExists(dynlibPath):
        check clang(dynlibPath, dynlibPath.toDylib, "-shared")
        flags = &"--passL:\"-Wl,-rpath,{workdir}\""

      let bindingsSource = generate(
        workdir/cHeader,
        enumMode = f.enumMode, enumOptions = f.enumOptions,
        linkMode = f.linkMode, dynLibName = f.dynLibName, dynLibPath = f.dynLibPath,
      )
      (workdir/bindings).writeFile(bindingsSource)
      check nim(f.testType, workdir/target, flags)

const cpp = "cpp"
const cppHeader = "header.hpp"
const cppFeatures = [
  (check, "empty_files"),
  (check, "big"),
  (check, "ordering_templates"),
  (check, "ordering_forward_templates"),
  (check, "template_generics"),
  (check, "references"),
  (check, "enums_scoped"),
  (check, "externc"),
  (check, "defines"),
  (run,   "enums_unscoped"),
]


suite "Henka C++ should support":
  for (action, feature) in cppFeatures:
    test feature.replace("_", " "):
      let workdir = baseDir/cpp/feature
      let bindingsSource = generate(workdir/cppHeader, isCpp = true)
      (workdir/bindings).writeFile(bindingsSource)
      check nim(action, workdir/target)

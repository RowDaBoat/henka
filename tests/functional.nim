import std/[unittest, os, osproc, strformat, strutils]
import ../src/henka


proc nim(action: string, file: string): bool =
  let (output, exitCode) = execCmdEx(&"nim {action} {quoteShell(file)}")
  if exitCode != 0:
    echo output
  result = exitCode == 0

const bindings = "bindings.nim"
const target = "target.nim"
const baseDir = currentSourcePath().parentDir()

const check = "check"
const run = "r"

proc feature(
  testType: string,
  name: string,
  enumMode: EnumMode = EnumMode.Default,
  enumOptions: EnumOptions = EnumOptions.Default
): (string, string, EnumMode, EnumOptions) =
  (testType, name, enumMode, enumOptions)


const c = "c"
const cHeader = "header.h"
const cFeatures = [
  feature(check, "empty_files"),
  feature(run,   "macros"),
  feature(check, "builtin_types"),
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
  feature(check, "not_regress_on_bugs"),
]

suite "Henka C should support":
  for (action, name, eMode, eOpts) in cFeatures:
    test name.replace("_", " "):
      let workdir = baseDir/c/name
      let bindingsSource = generate(workdir/cHeader, enumMode = eMode, enumOptions = eOpts)
      (workdir/bindings).writeFile(bindingsSource)
      check nim(action, workdir/target)

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
  (run,   "enums_unscoped"),
]

suite "Henka C++ should support":
  for (action, feature) in cppFeatures:
    test feature.replace("_", " "):
      let workdir = baseDir/cpp/feature
      let bindingsSource = generate(workdir/cppHeader, isCpp = true)
      (workdir/bindings).writeFile(bindingsSource)
      check nim(action, workdir/target)

import std/[unittest, os, osproc, strformat, strutils]
import ../src/henka


proc nim(action: string, file: string): bool =
  let (output, exitCode) = execCmdEx(&"nim check {quoteShell(file)}")
  if exitCode != 0:
    echo output
  result = exitCode == 0

const bindings = "bindings.nim"
const target = "target.nim"
const baseDir = currentSourcePath().parentDir()

const check = "check"
const run = "r"

const c = "c"
const cHeader = "header.h"
const cFeatures = [
  (check, "empty_files"),
  (run,   "macros"),
  (check, "builtin_types"),
  # (run,   "enums"),
  (run,   "enums_pure"),
  (run,   "enums_to_cint"),
  (run,   "enums_to_const"),
  (run,   "enums_to_distinct"),
  (run,   "enums_to_enums"),
  (check, "structs"),
  (check, "inner_structs"),
  (run,   "unions"),
  (run,   "inner_unions"),
  (check, "pointers"),
  (check, "function_pointers"),
  (check, "typedefs"),
  (check, "forward_declarations"),
  (check, "variables"),
  (check, "functions"),
  (check, "passthrough_pragmas"),
  (check, "respect_ordering"),
  (check, "not_regress_on_bugs")
]

suite "Henka C should support":
  for (action, feature) in cFeatures:
    test feature.replace("_", " "):
      let workdir = baseDir/c/feature
      let (eMode, eOpts) = case feature
        of "enums_to_cint":     (EnumMode.Cint, EnumOptions.Default)
        of "enums_to_const":    (EnumMode.Const, EnumOptions.Default)
        of "enums_to_distinct": (EnumMode.Cint, {EnumOption.Distinct})
        else:                   (EnumMode.Default, EnumOptions.Default)
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
  # (run,   "enums"),
]

suite "Henka C++ should support":
  for (action, feature) in cppFeatures:
    test feature.replace("_", " "):
      let workdir = baseDir/cpp/feature
      let bindingsSource = generate(workdir/cppHeader, isCpp = true)
      (workdir/bindings).writeFile(bindingsSource)
      check nim(action, workdir/target)

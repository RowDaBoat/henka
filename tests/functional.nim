import std/[unittest, os, osproc, strformat, strutils]
import ../src/henka/generator


proc nim(action: string, file: string): bool =
  let (output, exitCode) = execCmdEx(&"nim check {quoteShell(file)}")
  if exitCode != 0:
    echo output
  result = exitCode == 0

const header = "header.h"
const bindings = "bindings.nim"
const target = "target.nim"
const baseDir = currentSourcePath().parentDir()

const check = "check"
const run = "r"

const c = "c"
const cFeatures = [
  (check, "empty_files"),
  (run,   "macros"),
  (check, "builtin_types"),
  (run,   "enums"),
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
  (check, "passthrough_pragmas")
]

suite "Henka C should support":
  for (action, feature) in cFeatures:
    test feature.replace("_", " "):
      let workdir = baseDir/c/feature
      let bindingsSource = generate(workdir/header)
      (workdir/bindings).writeFile(bindingsSource)
      check nim(action, workdir/target)

const cpp = "cpp"
const cppFeatures = [
  (check, "empty_files"),
]

suite "Henka C++ should support":
  for (action, feature) in cppFeatures:
    test feature.replace("_", " "):
      let workdir = baseDir/cpp/feature
      let bindingsSource = generate(workdir/header, isCpp = true)
      (workdir/bindings).writeFile(bindingsSource)
      check nim(action, workdir/target)

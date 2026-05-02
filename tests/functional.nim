import std/[unittest, os, osproc, strformat]
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

const features = [
  (check, "empty_files"),
  (check, "builtin_types"),
  (run,   "enums"),
  (check, "structs"),
  (check, "inner_structs"),
  (run,   "unions"),
  (run,   "inner_unions"),
  (check, "pointers"),
  (check, "function_pointers"),
  (check, "typedefs"),
  (check, "variables"),
  (check, "functions")
]

suite "Henka should support":
  for (action, feature) in features:
    test feature:
      let workdir = baseDir/feature
      let bindingsSource = generate(workdir/header)
      (workdir/bindings).writeFile(bindingsSource)
      check nim(action, workdir/target)

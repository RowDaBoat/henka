import std/[unittest, os, osproc]
import ../src/henka/generator


proc nimcheck(file: string): bool =
  let (output, exitCode) = execCmdEx("nim check " & quoteShell(file))
  if exitCode != 0:
    echo output
    return false
  return true


const header = "header.h"
const bindings = "bindings.nim"
const target = "target.nim"
const baseDir = currentSourcePath().parentDir()

const features = [
  "emptyfile",
  "types",
  "variables",
  "functions",
  "innerstructs",
  "anonunions",
]

suite "Henka should support":
  for feature in features:
    test feature:
      let workdir = baseDir/feature
      let bindingsSource = generate(workdir/header)
      (workdir/bindings).writeFile(bindingsSource)
      check nimcheck(workdir/target)

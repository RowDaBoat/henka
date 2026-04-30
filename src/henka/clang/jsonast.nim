# @fileovewview Old -ast-dump=json helper, for reference
import std/[os, osproc, strformat, strutils, sequtils]

proc error*(message: string) =
  stderr.writeLine message
  quit(1)

proc compileAstFrom*(headerPaths: seq[string], extraArgs: string = ""): string =
  let wrapperPath = getCurrentDir() / "_henka_tmp.h"
  let wrapperContent = headerPaths.mapIt(&"#include \"{it}\"").join("\n")

  writeFile(wrapperPath, wrapperContent)
  defer: removeFile(wrapperPath)

  let flags = "clang -fsyntax-only -x c -Xclang -ast-dump=json"
  let includeDirs = headerPaths.mapIt(it.parentDir).deduplicate.mapIt("-I " & quoteShell(it)).join(" ")
  let extra = if extraArgs.len > 0: " " & extraArgs else: ""
  let stderrPath = getTempDir() / "henka_clang.err"
  let cmd = &"{flags} {includeDirs}{extra} {quoteShell(wrapperPath)} 2>{quoteShell(stderrPath)}"
  let (output, exitCode) = execCmdEx(cmd)

  if exitCode != 0:
    error readFile(stderrPath)

  output

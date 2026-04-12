import std/[os, osproc, strformat]
import error


proc compileAstFrom*(headerPath: string): string =
  let flags = "clang -fsyntax-only -x c -Xclang -ast-dump=json"
  let includes = "-I " & quoteShell(headerPath.parentDir())
  let header = quoteShell(headerPath)
  let stderrPath = getTempDir() / "henka_clang.err"
  let cmd = &"{flags} {includes} {header} 2>{quoteShell(stderrPath)}"
  let (output, exitCode) = execCmdEx(cmd)
  let compilationFailed = exitCode != 0

  if compilationFailed:
    error readFile(stderrPath)

  output

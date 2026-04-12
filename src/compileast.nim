import std/[os, osproc, strformat]


proc compileAstFrom*(headerPath: string): string =
  let flags = "clang -fsyntax-only -x c -Xclang -ast-dump=json"
  let includes = "-I " & quoteShell(headerPath.parentDir())
  let header = quoteShell(headerPath)
  let cmd = &"{flags} {includes} {header} 2>/dev/null"
  execCmdEx(cmd)[0]

import std/[macros, os]
import bindings


macro getPragma(fn: typed, nane:string): untyped =
  let impl = fn.getImpl()

  for pragma in impl.pragma:
    if pragma.kind == nnkExprColonExpr and pragma[0].strVal == nane.strVal:
      return pragma[1]

  error(nane.strVal & " pragma not found", fn)


proc toDylib(path: string): string =
  let (dir, name, _) = splitFile(path)
  when defined(windows): dir / (name & ".dll")
  elif defined(macosx):  dir / ("lib" & name & ".dylib")
  else:                  dir / ("lib" & name & ".so")


assert hello.getPragma("dynlib") == "dynlib".toDylib
assert $hello() == "Hello from dynlib."

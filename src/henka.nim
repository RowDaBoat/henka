import std/os
import ./henka/[base, callbacks, generator]
export base, callbacks, generator

when isMainModule:
  import ./henka/cli
  run()

import bindings

proc myCallback(a0: cint) {.cdecl.} = discard
proc myBinary(a0: cint, a1: cint): cint {.cdecl.} = a0 + a1

apply_callback(myCallback, 0)
discard apply_binary(myBinary, 1, 2)

var h: Handler
var p: pointer

h.on_event = myCallback
when compiles(h.on_event = p):
  {.error: "on_event should not accept a raw pointer".}

h.combine = myBinary
when compiles(h.combine = p):
  {.error: "combine should not accept a raw pointer".}

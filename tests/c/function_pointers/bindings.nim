type
  Handler* = struct_Handler
  struct_Handler* {.bycopy, importc:"struct Handler", header:"header.h".} = object
    on_event* :proc (a0 :cint) {.cdecl.}
    combine* :proc (a0 :cint; a1 :cint) :cint {.cdecl.}
proc apply_callback*(cb :proc (a0 :cint) {.cdecl.}; value :cint) {.importc:"apply_callback", cdecl, header:"header.h".}
proc apply_binary*(op :proc (a0 :cint; a1 :cint) :cint {.cdecl.}; a :cint; b :cint) :cint {.importc:"apply_binary", cdecl, header:"header.h".}

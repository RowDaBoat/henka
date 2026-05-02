type
  Node* = struct_Node
  struct_Node* {.bycopy, importc:"struct Node", header:"header.h".} = object
    value* :cint
    next* :ptr struct_Node
proc take_void_ptr*(p :pointer) {.importc:"take_void_ptr", cdecl, header:"header.h".}
proc take_int_ptr*(p :ptr cint) {.importc:"take_int_ptr", cdecl, header:"header.h".}
proc take_float_ptr*(p :ptr cfloat) {.importc:"take_float_ptr", cdecl, header:"header.h".}
proc take_string*(s :cstring) {.importc:"take_string", cdecl, header:"header.h".}
proc take_const_string*(s :cstring) {.importc:"take_const_string", cdecl, header:"header.h".}
proc take_ptr_to_ptr*(pp :ptr ptr cint) {.importc:"take_ptr_to_ptr", cdecl, header:"header.h".}
proc return_int_ptr*() :ptr cint {.importc:"return_int_ptr", cdecl, header:"header.h".}
proc return_string*() :cstring {.importc:"return_string", cdecl, header:"header.h".}

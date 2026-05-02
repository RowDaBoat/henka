type
  B* = struct_B
  A* = struct_A
  D* = struct_D
  C* = struct_C
  struct_B* {.bycopy, importc:"struct B", header:"header.h".} = object
    x* :cint
    y* :cint
  struct_A* {.bycopy, importc:"struct A", header:"header.h".} = object
    b* :ptr struct_B
  struct_D* {.bycopy, importc:"struct D", header:"header.h".} = object
    v* :cint
  struct_C* {.bycopy, importc:"struct C", header:"header.h".} = object
    d* :ptr struct_D
proc c*(a :struct_C) {.importc:"c", cdecl, header:"header.h".}

type
  Point* = struct_Point
  struct_Point* {.bycopy, importc:"struct Point", header:"header.h".} = object
    x* :cint
    y* :cint
proc no_return*() {.importc:"no_return", cdecl, header:"header.h".}
proc return_int*() :cint {.importc:"return_int", cdecl, header:"header.h".}
proc return_float*() :cfloat {.importc:"return_float", cdecl, header:"header.h".}
proc add*(a :cint; b :cint) :cint {.importc:"add", cdecl, header:"header.h".}
proc addf*(a :cfloat; b :cfloat) :cfloat {.importc:"addf", cdecl, header:"header.h".}
proc string_length*(s :cstring) :cint {.importc:"string_length", cdecl, header:"header.h".}
proc greeting*() :cstring {.importc:"greeting", cdecl, header:"header.h".}
proc make_point*(x :cint; y :cint) :struct_Point {.importc:"make_point", cdecl, header:"header.h".}
proc point_sum*(p :struct_Point) :cint {.importc:"point_sum", cdecl, header:"header.h".}
proc point_add*(a :struct_Point; b :struct_Point) :struct_Point {.importc:"point_add", cdecl, header:"header.h".}
proc apply*(fn :proc (a0 :cint) :cint {.cdecl.}; value :cint) :cint {.importc:"apply", cdecl, header:"header.h".}
proc foreach*(arr :ptr cint; len :cint; fn :proc (a0 :cint) {.cdecl.}) {.importc:"foreach", cdecl, header:"header.h".}

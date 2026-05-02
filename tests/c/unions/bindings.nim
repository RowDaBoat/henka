type
  Data* = union_Data
  Point* = struct_Point
  Value* = union_Value
  union_Data* {.bycopy, importc:"union Data", header:"header.h".} = object
    i* :cint
    f* :cfloat
    c* :cchar
  struct_Point* {.bycopy, importc:"struct Point", header:"header.h".} = object
    x* :cint
    y* :cint
  union_Value* {.bycopy, importc:"union Value", header:"header.h".} = object
    i* :cint
    f* :cfloat
    p* :struct_Point
    raw* :pointer

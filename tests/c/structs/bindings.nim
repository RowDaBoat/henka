type
  Empty* = struct_Empty
  Point* = struct_Point
  Rect* = struct_Rect
  Node* = struct_Node
  Canvas* = struct_Canvas
  struct_Empty* {.incompleteStruct, importc:"struct Empty", header:"header.h".} = object
  struct_Point* {.bycopy, importc:"struct Point", header:"header.h".} = object
    x* :cint
    y* :cint
  struct_Rect* {.bycopy, importc:"struct Rect", header:"header.h".} = object
    origin* :struct_Point
    size* :struct_Point
  struct_Node* {.bycopy, importc:"struct Node", header:"header.h".} = object
    value* :cint
    next* :ptr struct_Node
  struct_Canvas* {.bycopy, importc:"struct Canvas", header:"header.h".} = object
    bounds* :ptr struct_Rect
    cursor* :ptr struct_Point

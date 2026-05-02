type
  InnerA* = union_InnerA
  OuterA* = struct_OuterA
  InnerB* = union_InnerB
  OuterB* = struct_OuterB
  OuterC* = struct_OuterC
  OuterD* = struct_OuterD
  union_InnerA* {.bycopy, importc:"union InnerA", header:"header.h".} = object
    i* :cint
    f* :cfloat
  struct_OuterA* {.bycopy, importc:"struct OuterA", header:"header.h".} = object
    a* :union_InnerA
  union_InnerB* {.bycopy, importc:"union InnerB", header:"header.h".} = object
    i* :cint
    f* :cfloat
  struct_OuterB* {.bycopy, importc:"struct OuterB", header:"header.h".} = object
    a* :union_InnerB
  union_OuterC_unnamed0* {.bycopy, importc:"OuterC_unnamed0", header:"header.h".} = object
    i* :cint
    f* :cfloat
  struct_OuterC* {.bycopy, importc:"struct OuterC", header:"header.h".} = object
    a* :union_OuterC_unnamed0
  union_OuterD_unnamed0* {.bycopy, importc:"OuterD_unnamed0", header:"header.h".} = object
    i* :cint
    f* :cfloat
  struct_OuterD* {.bycopy, importc:"struct OuterD", header:"header.h".} = object
    unnamed0* :union_OuterD_unnamed0

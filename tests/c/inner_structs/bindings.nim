type
  InnerA* = struct_InnerA
  OuterA* = struct_OuterA
  InnerB* = struct_InnerB
  OuterB* = struct_OuterB
  OuterC* = struct_OuterC
  OuterD* = struct_OuterD
  struct_InnerA* {.bycopy, importc:"struct InnerA", header:"header.h".} = object
    a* :cint
  struct_OuterA* {.bycopy, importc:"struct OuterA", header:"header.h".} = object
    a* :struct_InnerA
  struct_InnerB* {.bycopy, importc:"struct InnerB", header:"header.h".} = object
    a* :cint
  struct_OuterB* {.bycopy, importc:"struct OuterB", header:"header.h".} = object
    a* :struct_InnerB
  struct_OuterC_unnamed0* {.bycopy, importc:"OuterC_unnamed0", header:"header.h".} = object
    a* :cint
  struct_OuterC* {.bycopy, importc:"struct OuterC", header:"header.h".} = object
    a* :struct_OuterC_unnamed0
  struct_OuterD* {.bycopy, importc:"struct OuterD", header:"header.h".} = object
    a* :cint

type
  struct_OuterA* {.bycopy, importc:"struct OuterA", header:"inline.h".} = object
    a* :struct_InnerA
  OuterA* = struct_OuterA
  struct_OuterB* {.bycopy, importc:"struct OuterB", header:"inline.h".} = object
    a* :struct_InnerB
  OuterB* = struct_OuterB
  struct_OuterC* {.bycopy, importc:"struct OuterC", header:"inline.h".} = object
    a* :struct_(unnamed struct at butcher/tests/inline.h:11:5)
  OuterC* = struct_OuterC
  struct_OuterD* {.incompleteStruct, importc:"struct OuterD", header:"inline.h".} = object
  OuterD* = struct_OuterD

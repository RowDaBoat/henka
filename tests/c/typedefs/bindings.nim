type
  Int32* = cint
  Float32* = cfloat
  UInt32* = cuint
  Byte* = cchar
  enum_Priority* = cint
  Priority* = enum_Priority
  enum_Named* = cint
  Named* = enum_Named
  IntPtr* = ptr cint
  String* = cstring
  Handle* = pointer
  Comparator* = proc (a0 :cint; a1 :cint) :cint {.cdecl.}
  Callback* = proc () {.cdecl.}
  Vec3* = struct_Vec3
  Tagged* = union_Tagged
  Node* = struct_Node
  List* = ptr struct_Node
  TreeNode* = struct_TreeNode
  Tree* = ptr struct_TreeNode
  Point* {.bycopy, importc:"Point", header:"header.h".} = object
    x* :cint
    y* :cint
  struct_Vec3* {.bycopy, importc:"struct Vec3", header:"header.h".} = object
    x* :cfloat
    y* :cfloat
    z* :cfloat
  Number* {.bycopy, importc:"Number", header:"header.h".} = object
    i* :cint
    f* :cfloat
  union_Tagged* {.bycopy, importc:"union Tagged", header:"header.h".} = object
    i* :cint
    f* :cfloat
    c* :cchar
  struct_Node* {.bycopy, importc:"struct Node", header:"header.h".} = object
    value* :cint
    next* :ptr struct_Node
  struct_TreeNode* {.bycopy, importc:"struct TreeNode", header:"header.h".} = object
    value* :cint
    left* :ptr struct_TreeNode
    right* :ptr struct_TreeNode
const
  Low* :enum_Priority= 0
  Medium* :enum_Priority= 1
  High* :enum_Priority= 2
  On* :enum_Named= 0
  Off* :enum_Named= 1

import bindings

var p: pointer
var i: cint
var f: cfloat
var s: cstring
var ip: ptr cint
var n: Node

take_void_ptr(p)
take_void_ptr(addr i)
take_void_ptr(addr f)
take_void_ptr(s)
take_void_ptr(ip)
take_void_ptr(addr n)

take_int_ptr(addr i)
when compiles(take_int_ptr(addr f)):
  {.error: "take_int_ptr should not accept ptr cfloat".}
elif compiles(take_int_ptr(p)):
  {.error: "take_int_ptr should not accept untyped pointer".}

take_float_ptr(addr f)
when compiles(take_float_ptr(addr i)):
  {.error: "take_float_ptr should not accept ptr cint".}
elif compiles(take_float_ptr(p)):
  {.error: "take_int_ptr should not accept untyped pointer".}

take_string(s)
when compiles(take_string(addr i)):
  {.error: "take_string should not accept ptr cint".}
elif compiles(take_string(p)):
  {.error: "take_int_ptr should not accept untyped pointer".}

take_const_string(s)
when compiles(take_const_string(addr i)):
  {.error: "take_const_string should not accept ptr cint".}
elif compiles(take_const_string(p)):
  {.error: "take_const_string should not accept untyped pointer".}

take_ptr_to_ptr(addr ip)
when compiles(take_ptr_to_ptr(addr i)):
  {.error: "take_ptr_to_ptr should not accept ptr cint".}
elif compiles(take_ptr_to_ptr(p)):
  {.error: "take_ptr_to_ptr should not accept untyped pointer".}

let ri: ptr cint = return_int_ptr()
let rs: cstring = return_string()

import bindings

let rb: bool      = return_bool()
let rc: cchar     = return_char()
let rs: cshort    = return_short()
let ri: cint      = return_int()
let rl: clong     = return_long()
let rf: cfloat    = return_float()
let rd: cdouble   = return_double()
let ru: cuint     = return_uint()
let rp: pointer   = return_void_ptr()
let rstr: cstring = return_string()

take_bool(rb)
take_char(rc)
take_short(rs)
take_int(ri)
take_long(rl)
take_float(rf)
take_double(rd)
take_uint(ru)
take_pointer(rp)
take_string(rstr)


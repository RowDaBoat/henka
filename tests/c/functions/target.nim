{.compile: "impl.c".}

import bindings

# void return
no_return()

# builtin returns
let i: cint = return_int()
assert i == 42
let f: cfloat = return_float()
assert f == 3.14f

# builtin params
assert add(2, 3) == 5
assert addf(1.5, 2.5) == 4.0f

# string params and return
assert string_length("hello") == 5
let g: cstring = greeting()
assert g == "hello"

# struct param and return
let p = make_point(3, 4)
assert p.x == 3
assert p.y == 4
assert point_sum(p) == 7

let q = point_add(make_point(1, 2), make_point(10, 20))
assert q.x == 11
assert q.y == 22

# function pointer callback
proc double_it(a0: cint): cint {.cdecl.} = a0 * 2

assert apply(double_it, 5) == 10

var total: cint = 0

proc accumulate(a0: cint) {.cdecl.} = total += a0

var arr = [1.cint, 2, 3, 4]
foreach(addr arr[0], arr.len.cint, accumulate)
assert total == 10

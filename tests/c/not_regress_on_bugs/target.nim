import bindings

var f = cast[ptr FlexArray](alloc0(2 * sizeof(cint)))
f.count = 1
f.data[0] = 42

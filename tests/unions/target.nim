import bindings

var d: Data
d.i = 42
assert d.i == 42
d.f = 3.14
assert d.i != 42
d.c = 'x'
assert d.f != 3.14

var v: Value
v.i = 10
assert v.i == 10
v.f = 2.5
assert v.i != 10
v.p = Point(x: 1, y: 2)
assert v.p.x == 1
assert v.p.y == 2
v.raw = nil
assert v.p.x != 1

import bindings

var r: Ref[cint]
r.count = 1

var m: Map[cint, cfloat]
m.size = 5

var v: Vector[Ref[cint]]
v.size = 10
v.capacity = 20

var fv: FloatVec
fv.size = 1

var cm: ComplexMap
cm.size = 2

var c: Container
c.items.size = 1
c.lookup.size = 2
c.nested.size = 3

import bindings

var x: MoreDerived
x.b = 1 # Base
x.d = 2 # Derived
x.m = 3 # Self
doAssert x.b == 1
doAssert x.d == 2
doAssert x.m == 3

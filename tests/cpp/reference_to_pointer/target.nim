import bindings

var n: ptr Node = nil
acquire(n)
doAssert n != nil

n.value = 7

var m: ptr Node = nil
acquire(m)
doAssert m.value == 7

m.value = 42
doAssert n.value == 42

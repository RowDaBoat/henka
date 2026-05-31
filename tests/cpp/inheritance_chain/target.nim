import bindings

proc main() =
  var x: MoreDerived
  x.b = 1        # field inherited from Base
  x.d = 2        # field inherited from Derived
  x.m = 3        # own field
  doAssert x.b == 1
  doAssert x.d == 2
  doAssert x.m == 3

main()

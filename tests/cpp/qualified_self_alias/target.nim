import bindings

proc main() =
  var i: Inner
  i.x = 5
  doAssert i.x == 5

main()

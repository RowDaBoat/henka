import bindings

proc main() =
  # The `Node *&` out-parameter binds as `var ptr Node`.
  var n: ptr Node = nil
  acquire(n)
  doAssert n != nil

  n.value = 7                 # set through the acquired pointer

  var m: ptr Node = nil
  acquire(m)                  # same shared node
  doAssert m.value == 7       # get: reads back what was written

  m.value = 42
  doAssert n.value == 42      # both pointers alias the same node

main()

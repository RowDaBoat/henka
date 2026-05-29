import bindings

static:
  doAssert declared(Container)
  doAssert declared(Color)
  doAssert declared(Type)         # nested enum, emitted unqualified
  doAssert declared(toType)       # operator Type -> toType
  doAssert declared(Body)

  doAssert compiles(block:
    var c: Container
    let n: cuint = size(c)
    discard n)

  doAssert compiles(block:
    var b: Body
    b.storage = b.points)

import bindings

static:
  doAssert declared(sZero)
  doAssert declared(sReplicate)
  doAssert compiles(Vec3.sZero())
  doAssert compiles(Vec4.sZero())
  doAssert compiles(Vec3.sReplicate(1.0'f32))
  doAssert compiles(Vec4.sReplicate(1.0'f32))
  doAssert Vec3.sZero() is Vec3
  doAssert Vec4.sZero() is Vec4

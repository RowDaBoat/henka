import bindings

static:
  doAssert declared(Vec4)
  doAssert compiles(Vec4_create(1.0'f32, 2.0'f32, 3.0'f32, 4.0'f32))
  doAssert compiles(Vec4_create())
  doAssert not compiles(Vec4_create([1.0'f32, 2.0'f32, 3.0'f32, 4.0'f32]))

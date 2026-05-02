{.compile: "impl.cpp".}

# This test imports the generated bindings file.
# It will fail to compile until the converter generates test_cpp_bindings.nim.
import ./bindings

proc printf(format :cstring) {.importc, varargs, header: "<cstdio>".}

proc main =
  let a = Vec3_create(1.0, 2.0, 3.0)
  let b = Vec3_create(4.0, 5.0, 6.0)
  let z = zero()

  printf("a = (%g, %g, %g)\n", a.x, a.y, a.z)
  printf("b = (%g, %g, %g)\n", b.x, b.y, b.z)
  printf("zero = (%g, %g, %g)\n", z.x, z.y, z.z)

  let sum = a + b
  let diff = a - b
  let scaled = a * 2.0
  let neg = -a
  printf("a + b = (%g, %g, %g)\n", sum.x, sum.y, sum.z)
  printf("a - b = (%g, %g, %g)\n", diff.x, diff.y, diff.z)
  printf("a * 2 = (%g, %g, %g)\n", scaled.x, scaled.y, scaled.z)
  printf("-a = (%g, %g, %g)\n", neg.x, neg.y, neg.z)

  printf("a == b: %d\n", a == b)
  printf("a != b: %d\n", a != b)
  printf("a == a: %d\n", a == a)

  var aa = Vec3_create(1.0, 2.0, 3.0)
  printf("a[0] = %g\n", aa[0])
  printf("a[1] = %g\n", aa[1])
  printf("a[2] = %g\n", aa[2])

  var c = Vec3_create(1.0, 1.0, 1.0)
  c += a
  printf("c += a: (%g, %g, %g)\n", c.x, c.y, c.z)
  c -= b
  printf("c -= b: (%g, %g, %g)\n", c.x, c.y, c.z)
  c *= 3.0
  printf("c *= 3: (%g, %g, %g)\n", c.x, c.y, c.z)

  printf("length(a) = %g\n", a.length())
  printf("dot(a, b) = %g\n", dot(a, b))

  let cr = cross(a, b)
  printf("cross(a, b) = (%g, %g, %g)\n", cr.x, cr.y, cr.z)

  printf("clamp(5.0, 0.0, 3.0) = %g\n", test_cpp_bindings.clamp(5.0.cfloat, 0.0.cfloat, 3.0.cfloat))
  printf("clamp(-1.0, 0.0, 3.0) = %g\n", test_cpp_bindings.clamp((-1.0).cfloat, 0.0.cfloat, 3.0.cfloat))
  printf("clamp(2.0, 0.0, 3.0) = %g\n", test_cpp_bindings.clamp(2.0.cfloat, 0.0.cfloat, 3.0.cfloat))

  let col = Color.Green
  printf("color = %d\n", col.cint)

  var v2 :Vec2[cfloat]
  v2.x = 10.0
  v2.y = 20.0
  printf("v2 = (%g, %g)\n", v2.x, v2.y)

  let circle = Circle_create(5.0)
  printf("circle.name = %s\n", circle.name())
  printf("circle.area = %g\n", circle.area())
  printf("circle.radius = %g\n", circle.radius)

  printf("shape.name = %s\n", circle.Shape.name())
  printf("shape.area = %g\n", circle.Shape.area())

  let dc = DrawableCircle_create(3.0)
  printf("dc.name = %s\n", dc.name())
  printf("dc.area = %g\n", dc.area())
  printf("dc.radius = %g\n", dc.radius)

main()

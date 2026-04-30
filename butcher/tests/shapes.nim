type Circle* {.importc, bycopy, header: "tests/shapes.h".} = object
  radius*: cfloat

type Rectangle* {.importc, bycopy, header: "tests/shapes.h".} = object
  width*: cfloat
  height*: cfloat

type Triangle* {.importc, bycopy, header: "tests/shapes.h".} = object
  a*: cfloat
  b*: cfloat
  c*: cfloat

type Line* {.importc, bycopy, header: "tests/shapes.h".} = object
  length*: cfloat

type ShapeKind* {.size: sizeof(cint).} = enum
  ShapeKindCircle,
  ShapeKindRectangle,
  ShapeKindTriangle,
  ShapeKindLine

type ShapeData* {.importc, union, header: "tests/shapes.h".} = object
  circle*: Circle
  rectangle*: Rectangle
  triangle*: Triangle
  line*: Line

type Shape* {.importc, bycopy, header: "tests/shapes.h".} = object
  kind*: ShapeKind
  data*: ShapeData

type ShapeCalculatorFn* = proc(a0: Shape): cfloat {.cdecl.}
type ShapeContainsFn* = proc(a0: Shape, a1: Shape): cint {.cdecl.}
proc shape_perimeter*(shape: Shape): cfloat {.importc, cdecl, header: "tests/shapes.h".}
proc shape_area*(shape: Shape): cfloat {.importc, cdecl, header: "tests/shapes.h".}
proc triangleContainsCircle*(triangle: Triangle, circle: Circle): cint {.importc, cdecl, header: "tests/shapes.h".}

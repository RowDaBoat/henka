proc add*(a :cdouble; b :cdouble) :cdouble {.importjs:"add(@)".}
proc greet*(name :cstring) :cstring {.importjs:"greet(@)".}
const PI* :auto= 3.14159
type Vec2* = object
  x* :cdouble
  y* :cdouble
proc magnitude*(v :Vec2) :cdouble {.importjs:"magnitude(@)".}
type Color* = cdouble

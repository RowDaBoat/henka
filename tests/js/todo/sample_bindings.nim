type
  Vec2* = object
    x* :cdouble
    y* :cdouble
  Anonymous0* = object
    r* :cdouble
    g* :cdouble
    b* :cdouble
    a* :cdouble
  Color* = Anonymous0
proc add*(a :cdouble; b :cdouble) :cdouble {.importjs:"add(@)".}
proc greet*(name :cstring) :cstring {.importjs:"greet(@)".}
const PI* :cdouble= 3.14159
proc magnitude*(v :Vec2) :cdouble {.importjs:"magnitude(@)".}

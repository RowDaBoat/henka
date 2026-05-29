import bindings

static:
  doAssert declared(call)         # operator()        -> call
  doAssert declared(newArray)     # operator new[]    -> newArray
  doAssert declared(deleteArray)  # operator delete[] -> deleteArray
  doAssert declared(toVec3)       # operator Vec3     -> toVec3
  doAssert declared(r)            # operator"" _r     -> r
  doAssert declared(`|=`)         # operator|=
  doAssert declared(`&=`)         # operator&=
  doAssert declared(`^=`)         # operator^=
  doAssert declared(`<<=`)        # operator<<=
  doAssert declared(`>>=`)        # operator>>=
  doAssert declared(`%=`)         # operator%=

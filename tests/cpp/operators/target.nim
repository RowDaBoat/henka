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
  doAssert declared(AllocA)       # class is still bound despite its allocation operators
  doAssert declared(AllocB)
  # Member operator new/delete are skipped, so no pointer-taking new/delete
  # overloads leak in from the bindings (only Nim's builtins remain).
  when compiles(new(0'u64)):               {.error: "member operator new must be skipped".}
  when compiles(delete(pointer(nil))):     {.error: "member operator delete must be skipped".}

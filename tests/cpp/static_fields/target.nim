import bindings

proc roundtrip() =
  var w: Widget
  Widget.sInstance = addr w          # setter
  doAssert Widget.sInstance == addr w  # getter
  Widget.sInstance = nil

static:
  doAssert declared(sInstance)
  doAssert declared(`sInstance=`)
  doAssert Widget.sInstance is ptr Widget
  doAssert compiles(roundtrip())
  # const static members are skipped, so no accessor is generated.
  doAssert not declared(sMax)

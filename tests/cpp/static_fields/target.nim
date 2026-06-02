import bindings

proc roundtrip() =
  var w: Widget
  Widget.sInstance = addr w
  doAssert Widget.sInstance == addr w
  Widget.sInstance = nil

static:
  doAssert declared(sInstance)
  doAssert declared(`sInstance=`)
  doAssert Widget.sInstance is ptr Widget
  doAssert compiles(roundtrip())
  # const static members are skipped for now.
  doAssert not declared(sMax)

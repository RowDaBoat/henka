import bindings

# Basic scoped enum
when Color.Red.int != 0: {.error: "Color.Red must be 0".}
when Color.Green.int != 1: {.error: "Color.Green must be 1".}
when Color.Blue.int != 2: {.error: "Color.Blue must be 2".}

# Small backing type
when SmallFlag.None.int != 0: {.error: "SmallFlag.None must be 0".}
when SmallFlag.A.int != 1: {.error: "SmallFlag.A must be 1".}

# Negative values
when Signed.Neg.int != -10: {.error: "Signed.Neg must be -10".}
when Signed.Zero.int != 0: {.error: "Signed.Zero must be 0".}
when Signed.Pos.int != 10: {.error: "Signed.Pos must be 10".}

# Sparse — succ must not work
when compiles(succ(Sparse.A)): {.error: "succ must not work on sparse scoped enum".}

# In function signatures
when not compiles(get_color()): {.error: "get_color must be callable".}
when not compiles(set_color(Color.Red)): {.error: "set_color must accept Color".}

# In struct fields
var h: HasColor
h.value = 1
when not compiles(h.color): {.error: "HasColor must have color field".}

echo "enums_scoped passed"

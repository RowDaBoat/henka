import bindings

# =========================================
# Scoped enum (enum class Color)
# =========================================
# Must be a proper Nim enum, not cint alias
when Color.Red.int != 0: {.error: "Color.Red must be 0".}
when Color.Green.int != 1: {.error: "Color.Green must be 1".}
when Color.Blue.int != 2: {.error: "Color.Blue must be 2".}

# Must support type qualification
when not compiles(Color.Red): {.error: "Color.Red must be valid".}

# Ordering
when not (Color.Red < Color.Green): {.error: "Red must be < Green".}

# =========================================
# Scoped enum with small backing type
# =========================================
when SmallFlag.None.int != 0: {.error: "SmallFlag.None must be 0".}
when SmallFlag.A.int != 1: {.error: "SmallFlag.A must be 1".}
when SmallFlag.B.int != 2: {.error: "SmallFlag.B must be 2".}
when SmallFlag.C.int != 4: {.error: "SmallFlag.C must be 4".}

# =========================================
# Scoped enum with int backing
# =========================================
when Status.Ok.int != 0: {.error: "Status.Ok must be 0".}
when Status.Error.int != 1: {.error: "Status.Error must be 1".}
when Status.Pending.int != 2: {.error: "Status.Pending must be 2".}

# =========================================
# Large values
# =========================================
when BigEnum.Small.int != 0: {.error: "BigEnum.Small must be 0".}
when BigEnum.Large.int != 1000000: {.error: "BigEnum.Large must be 1000000".}
when BigEnum.Max.int != 0x7FFFFFFF: {.error: "BigEnum.Max must be 0x7FFFFFFF".}

# =========================================
# Negative values in scoped enum
# =========================================
when SignedEnum.Neg.int != -10: {.error: "SignedEnum.Neg must be -10".}
when SignedEnum.Zero.int != 0: {.error: "SignedEnum.Zero must be 0".}
when SignedEnum.Pos.int != 10: {.error: "SignedEnum.Pos must be 10".}

# =========================================
# Unscoped C++ enum (legacy, behaves like C)
# =========================================
when LegacyA.int != 0: {.error: "LegacyA must be 0".}
when LegacyB.int != 1: {.error: "LegacyB must be 1".}
when LegacyC.int != 2: {.error: "LegacyC must be 2".}

# =========================================
# Scoped enum in function signatures
# =========================================
when not compiles(get_color()): {.error: "get_color must be callable".}
when not compiles(set_color(Color.Red)): {.error: "set_color must accept Color".}

# =========================================
# Scoped enum in struct fields
# =========================================
var h: HasEnums
h.value = 1
when not compiles(h.color): {.error: "HasEnums must have color field".}
when not compiles(h.status): {.error: "HasEnums must have status field".}
when not compiles(h.flags): {.error: "HasEnums must have flags field".}

# =========================================
# Single value scoped enum
# =========================================
when Singleton.Only.int != 42: {.error: "Singleton.Only must be 42".}

# =========================================
# Sparse scoped enum (gaps)
# =========================================
when Sparse.A.int != 1: {.error: "Sparse.A must be 1".}
when Sparse.B.int != 10: {.error: "Sparse.B must be 10".}
when Sparse.C.int != 100: {.error: "Sparse.C must be 100".}

# Sparse/holed enum should NOT support succ/pred
when compiles(succ(Sparse.A)): {.error: "succ must not work on sparse scoped enum".}

# =========================================
# Stringify
# =========================================
when not compiles($Color.Red): {.error: "$Color.Red must compile".}

echo "All C++ enum tests passed"

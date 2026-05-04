import bindings

# Distinct mode: type is distinct cint, values are typed consts
assert Red is enum_Color
assert Green is enum_Color
assert Blue is enum_Color
assert FlagNone is enum_Flags
assert FlagRead is enum_Flags

# Must not be plain cint
assert Red isnot cint
assert FlagNone isnot cint

# Cannot mix types without conversion
when compiles(Red + FlagRead): {.error: "distinct types must not mix".}

# Can convert to int
assert Red.cint == 0
assert Green.cint == 1
assert Blue.cint == 2

echo "All enums_to_distinct tests passed"

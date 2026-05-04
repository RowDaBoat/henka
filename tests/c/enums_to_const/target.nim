import bindings

# Const mode: no type emitted, values are implicit comptime ints
assert Red == 0
assert Green == 1
assert Blue == 2
assert FlagNone == 0
assert FlagRead == 1
assert FlagWrite == 2

# Values must be plain ints, not typed
assert Red is int
assert Green is int

# Arithmetic works directly
assert Red + Green == 1
assert FlagRead + FlagWrite == 3

echo "All enums_to_const tests passed"

import bindings

# Bit flag enums should support sets
assert {FlagA, FlagB} is set[enum_BitFlag]
assert cast[int]({FlagA, FlagB}) == 3
assert cast[int]({FlagA, FlagB, FlagC, FlagD}) == 15

# FlagAll is a combination value, should equal the full set cast
assert FlagAll.int == cast[int]({FlagA, FlagB, FlagC, FlagD})

echo "enums_bitflags passed"

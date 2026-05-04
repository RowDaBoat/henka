import bindings

# Enum in function signatures
when not compiles(get_status()): {.error: "get_status must be callable".}
when not compiles(set_status(StatusOk)): {.error: "set_status must accept Status values".}

# Enum in struct fields
var h: HasEnum
h.value = 1
when not compiles(h.status): {.error: "HasEnum must have status field".}

echo "enums_in_signatures passed"

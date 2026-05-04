import bindings

when LegacyA.int != 0: {.error: "LegacyA must be 0".}
when LegacyB.int != 1: {.error: "LegacyB must be 1".}
when LegacyC.int != 2: {.error: "LegacyC must be 2".}

echo "enums_unscoped passed"

import bindings

# Basic enum values exist and have correct ordinals
when Red.int != 0: {.error: "Red must be 0".}
when Green.int != 1: {.error: "Green must be 1".}
when Blue.int != 2: {.error: "Blue must be 2".}

# Type qualification works (pure enum)
when not compiles(Color.Red): {.error: "Color.Red must be valid".}
when Color.Red != Red: {.error: "Color.Red must equal Red".}

# Flags enum
when FlagNone.int != 0: {.error: "FlagNone must be 0".}
when FlagRead.int != 1: {.error: "FlagRead must be 1".}
when FlagWrite.int != 2: {.error: "FlagWrite must be 2".}

# Ordering
when not (Red < Green): {.error: "Red must be < Green".}
when not (Green < Blue): {.error: "Green must be < Blue".}

# Stringify
when not compiles($Red): {.error: "$Red must compile".}

echo "All enum mode tests passed"

import bindings

when OptionNone.int != 0: {.error: "OptionNone must be 0".}
when OptionSome.int != 1: {.error: "OptionSome must be 1".}
when OptionAll.int != 2: {.error: "OptionAll must be 2".}

# typedef enum must produce a clean name
when not compiles(OptionEnum.OptionNone): {.error: "OptionEnum.OptionNone must be valid".}

echo "enums_typedef passed"

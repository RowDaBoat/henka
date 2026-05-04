import bindings

when HoledA.int != 2: {.error: "HoledA must be 2".}
when HoledB.int != 4: {.error: "HoledB must be 4".}
when HoledC.int != 89: {.error: "HoledC must be 89".}
when compiles(succ(HoledA)): {.error: "succ must not work on holed enum".}
when compiles(pred(HoledC)): {.error: "pred must not work on holed enum".}

echo "enums_holes passed"

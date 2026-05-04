import bindings

when MixedA.int != 0: {.error: "MixedA must be 0 (implicit)".}
when MixedB.int != 5: {.error: "MixedB must be 5 (explicit)".}
when MixedC.int != 6: {.error: "MixedC must be 6 (implicit after 5)".}
when MixedD.int != 20: {.error: "MixedD must be 20 (explicit)".}
when MixedE.int != 21: {.error: "MixedE must be 21 (implicit after 20)".}

echo "enums_mixed passed"

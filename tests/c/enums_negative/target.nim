import bindings

when SignedNeg.int != -1: {.error: "SignedNeg must be -1".}
when SignedZero.int != 0: {.error: "SignedZero must be 0".}
when SignedPos.int != 1: {.error: "SignedPos must be 1".}
when not (SignedNeg < SignedZero): {.error: "SignedNeg must be < SignedZero".}

echo "enums_negative passed"

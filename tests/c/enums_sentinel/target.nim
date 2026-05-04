import bindings

when SentinelA.int != 0: {.error: "SentinelA must be 0".}
when SentinelB.int != 1: {.error: "SentinelB must be 1".}
when SentinelForce32.int != 0x7FFFFFFF: {.error: "SentinelForce32 must be 0x7FFFFFFF".}

echo "enums_sentinel passed"

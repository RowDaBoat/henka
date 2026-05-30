import bindings

# Counter must be emitted exactly once, with its method bound a single time.
var c: Counter
discard c.increment(1)

discard seed(10)
discard reset(0)

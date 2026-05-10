import std/jsffi
import bindings

var obj: JsObject

# Object wrappers
partial(obj)
required(obj)
discard readonly(obj)
discard nonNull(obj)

# Key/value selectors
pick(obj)
omit(obj)
record(obj)
extract(obj)
exclude(obj)

# Function manipulation
retType(obj)
params(obj)
instType(obj)

# Promise/Async
awaited(obj)

# Iteration
iterate(obj)
`iterator`(obj)
iterableIterator(obj)
asyncIterable(obj)
asyncIterator(obj)
asyncIterableIterator(obj)

# Collections
useMap(obj)
useSet(obj)
useWeakMap(obj)
useWeakSet(obj)

# Keywords
getKeys(obj)
getUnknown(obj)
getAny(obj)

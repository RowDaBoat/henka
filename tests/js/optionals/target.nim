import std/options
import bindings

var config: Config
config.host = "localhost"
config.port = some(8080.0)
config.timeout = none(cdouble)
config.label = some("dev".cstring)

discard find(@["a".cstring, "b".cstring], proc(item: cstring): bool = true)
discard tryParse("42")
configure("localhost", some(8080.0), none(cdouble))

let found: Option[cstring] = findOrNull("key")
let count: Option[cdouble] = tryCount("input")
discard found
discard count

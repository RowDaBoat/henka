import bindings

var emitter: Emitter

discard parse("42".cstring)
discard parse(42.0)
discard stringify(42.0)
discard stringify(true)
emitter.emit("click", 10.0, 20.0)
emitter.emit("error", "code")

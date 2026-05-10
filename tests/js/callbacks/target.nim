import bindings

var cb: Callback
var pred: Predicate
var tf: Transform
var emitter: EventEmitter
forEach(@[1.0, 2.0], proc(item: cdouble) = discard)
discard map(@[1.0], proc(item: cdouble): cdouble = item)
emitter.on("click", proc(data: cstring) = discard)
emitter.off("click", proc(data: cstring) = discard)

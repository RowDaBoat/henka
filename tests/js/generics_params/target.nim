import std/jsffi
import bindings

var config: Config
config.host = "localhost"
config.port = 8080.0

let key: JsObject = getKey("host")
discard key

let val: cstring = identity("test")
let num: cdouble = identity(42.0)
discard val
discard num

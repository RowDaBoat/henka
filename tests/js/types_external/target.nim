import std/jsffi
import bindings

var decoder: Decoder
discard decoder.decode(JsObject())
discard decoder.buffer

let buf: ArrayBuffer = bindings.readFile("/tmp/data")
upload(JsObject())
discard buf

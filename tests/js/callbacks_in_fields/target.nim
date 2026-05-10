import std/jsffi
import std/options
import bindings

var reader: FileReader
discard reader.error
discard reader.onabort
discard reader.onload
discard reader.result

var target: EventTarget
discard target.onclick
discard target.onerror

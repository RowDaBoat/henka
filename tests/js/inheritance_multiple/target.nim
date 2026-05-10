import std/jsffi
import bindings

var readable: Readable
discard readable.read()

var writable: Writable
writable.write("data")

var closeable: Closeable
closeable.close()

var stream: Stream
discard stream.name()
discard stream.read()
stream.write("data")
stream.close()

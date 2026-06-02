import std/jsffi
import bindings

var my_pair: Pair
discard my_pair[0]
discard my_pair[1]
var my_named_pair: NamedPair
discard my_named_pair.first
discard my_named_pair.second
var stream: Stream
let result_pair = pair()
discard result_pair[0]
discard result_pair[1]
let result_triple = triple()
discard result_triple[0]
discard result_triple[1]
discard result_triple[2]
let result_named = named()
discard result_named.count
discard result_named.label
let result_tee = stream.tee()
discard result_tee[0]
discard result_tee[1]
let result_split = stream.split()
discard result_split.head
discard result_split.tail

import bindings

var list: List
discard list.items
discard list.names
discard sum(@[1.0, 2.0])
discard join(@["a".cstring, "b".cstring])
discard concat(@[1.0], @[2.0])
discard filter(@["a".cstring], proc(item: cstring): bool = true)
discard list.get(0.0)
list.append(1.0)

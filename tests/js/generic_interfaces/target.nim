import bindings

var list: Collection[cstring]
discard list.length
discard list.get(0.0)
list.add("item")

var pair: Pair[cstring, cdouble]
discard pair.key
discard pair.value

var strList: StringList
discard strList.join(", ")
discard strList.get(0.0)

var numPair: NumberPair
discard numPair.label
discard numPair.key

discard createList()
discard createPair()

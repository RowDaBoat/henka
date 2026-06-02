import std/jsffi
import bindings

var person: Person
discard getKey(toJs("name"))
discard getValue(person, toJs("age"))

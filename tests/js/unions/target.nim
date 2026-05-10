import bindings

var flexible: Flexible
discard flexible.value
discard parse(flexible.value)
discard coerce(flexible.value)
flex(flexible.value)
discard flexible.convert(flexible.value)

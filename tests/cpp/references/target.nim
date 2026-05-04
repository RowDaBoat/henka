import bindings

var v: Vec2
v.x = 1.0
v.y = 2.0

normalize(v)
let d = dot(v, v)

var a = Vec2(x: 1.0, y: 0.0)
var b = Vec2(x: 0.0, y: 1.0)
let s = add(a, b)

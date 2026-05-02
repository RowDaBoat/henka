import bindings

var e: Empty

for _ in e.fields:
  {.error: "Empty should have no fields".}

var p = Point(x: 1, y: 2)
var r = Rect(origin: Point(x: 0, y: 0), size: Point(x: 10, y: 20))

var c = Node(value: 3, next: nil)
var b = Node(value: 2, next: addr c)
var a = Node(value: 1, next: addr b)

var canvas: Canvas
canvas.bounds = addr r
canvas.cursor = addr p

import bindings

let v = newVec3(1.0, 2.0, 3.0)
discard v.x
discard v.y
discard v.z
discard v.length()
discard v.add(v)
discard v.scale(2.0)
discard zero()

let r = newRenderer("canvas", 800.0, 600.0)
discard r.canvas
discard r.width
discard r.height
r.clear()
r.drawLine(v, v)

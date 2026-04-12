{.compile: "shapes.c".}

import shapes

let myShapes = @[
  Shape(
    kind: ShapeKindCircle,
    data: ShapeData(circle: Circle(radius: 5.0))
  ),
  Shape(
    kind: ShapeKindRectangle,
    data: ShapeData(rectangle: Rectangle(width: 4.0, height: 6.0))
  ),
  Shape(
    kind: ShapeKindTriangle,
    data: ShapeData(triangle: Triangle(a: 3.0, b: 4.0, c: 5.0))
  ),
  Shape(
    kind: ShapeKindLine,
    data: ShapeData(line: Line(length: 7.0))
  )
]

for shape in myShapes:
  let perimeter = shape_perimeter(shape)
  let area = shape_area(shape)
  echo "perimeter=", perimeter, " area=", area

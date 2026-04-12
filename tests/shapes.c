#include "shapes.h"

#include <math.h>

float shape_perimeter(Shape shape) {
    switch (shape.kind) {
        case ShapeKindCircle:
            return 2.0f * (float)M_PI * shape.data.circle.radius;
        case ShapeKindRectangle:
            return 2.0f * (shape.data.rectangle.width + shape.data.rectangle.height);
        case ShapeKindTriangle:
            return shape.data.triangle.a + shape.data.triangle.b + shape.data.triangle.c;
        case ShapeKindLine:
            return shape.data.line.length;
    }
    return 0.0f;
}

float shape_area(Shape shape) {
    switch (shape.kind) {
        case ShapeKindCircle:
            return (float)M_PI * shape.data.circle.radius * shape.data.circle.radius;
        case ShapeKindRectangle:
            return shape.data.rectangle.width * shape.data.rectangle.height;
        case ShapeKindTriangle: {
            float s = (shape.data.triangle.a + shape.data.triangle.b + shape.data.triangle.c) / 2.0f;
            return sqrtf(s * (s - shape.data.triangle.a) * (s - shape.data.triangle.b) * (s - shape.data.triangle.c));
        }
        case ShapeKindLine:
            return 0.0f;
    }
    return 0.0f;
}

#ifndef SHAPES_H
#define SHAPES_H

typedef enum Cardinals {
    North = 0x1,
    South = 0x2,
    East = 0x4,
    West = 0x8,
    NorthWest = North | West,
    NorthEast = North | East,
    SouthWest = South | West,
    SouthEast = South | East
} Cardinals;

typedef struct Circle {
    float radius;
} Circle;

typedef struct Rectangle {
    float width;
    float height;
} Rectangle;

typedef struct Triangle {
    float a;
    float b;
    float c;
} Triangle;

typedef struct Line {
    float length;
} Line;

typedef enum ShapeKind {
    ShapeKindCircle,
    ShapeKindRectangle,
    ShapeKindTriangle,
    ShapeKindLine,
} ShapeKind;

typedef union ShapeData {
    Circle circle;
    Rectangle rectangle;
    Triangle triangle;
    Line line;
} ShapeData;

typedef struct Shape {
    ShapeKind kind;
    ShapeData data;
    float (*area)(struct Shape shape);
    float (*perimeter)(struct Shape shape);
    const char *(*describe)(struct Shape shape, unsigned int flags);
    void (*destroy)(void);
} Shape;

typedef float (*ShapeCalculatorFn)(Shape shape);
typedef int (*ShapeContainsFn)(struct Shape left, struct Shape right);

float shapePerimeter(Shape shape);
float shapeArea(Shape shape);
int triangleContainsCircle(struct Triangle triangle, struct Circle circle);
void shapeLog(const char *fmt, ...);

#endif /* SHAPES_H */

#include "header.hpp"
#include <cstdio>

using namespace math;
using namespace math::nested;

int main() {
    // Construction
    Vec3 a(1.0f, 2.0f, 3.0f);
    Vec3 b(4.0f, 5.0f, 6.0f);
    Vec3 z = Vec3::zero();

    printf("a = (%g, %g, %g)\n", a.x, a.y, a.z);
    printf("b = (%g, %g, %g)\n", b.x, b.y, b.z);
    printf("zero = (%g, %g, %g)\n", z.x, z.y, z.z);

    // Arithmetic operators
    Vec3 sum = a + b;
    Vec3 diff = a - b;
    Vec3 scaled = a * 2.0f;
    Vec3 neg = -a;
    printf("a + b = (%g, %g, %g)\n", sum.x, sum.y, sum.z);
    printf("a - b = (%g, %g, %g)\n", diff.x, diff.y, diff.z);
    printf("a * 2 = (%g, %g, %g)\n", scaled.x, scaled.y, scaled.z);
    printf("-a = (%g, %g, %g)\n", neg.x, neg.y, neg.z);

    // Comparison
    printf("a == b: %d\n", a == b);
    printf("a != b: %d\n", a != b);
    printf("a == a: %d\n", a == a);

    // Subscript
    printf("a[0] = %g\n", a[0]);
    printf("a[1] = %g\n", a[1]);
    printf("a[2] = %g\n", a[2]);

    // Compound assignment
    Vec3 c(1.0f, 1.0f, 1.0f);
    c += a;
    printf("c += a: (%g, %g, %g)\n", c.x, c.y, c.z);
    c -= b;
    printf("c -= b: (%g, %g, %g)\n", c.x, c.y, c.z);
    c *= 3.0f;
    printf("c *= 3: (%g, %g, %g)\n", c.x, c.y, c.z);

    // Length and dot
    printf("length(a) = %g\n", a.length());
    printf("dot(a, b) = %g\n", dot(a, b));

    // Cross product
    Vec3 cr = cross(a, b);
    printf("cross(a, b) = (%g, %g, %g)\n", cr.x, cr.y, cr.z);

    // Clamp
    printf("clamp(5.0, 0.0, 3.0) = %g\n", clamp(5.0f, 0.0f, 3.0f));
    printf("clamp(-1.0, 0.0, 3.0) = %g\n", clamp(-1.0f, 0.0f, 3.0f));
    printf("clamp(2.0, 0.0, 3.0) = %g\n", clamp(2.0f, 0.0f, 3.0f));

    // Enum
    Color col = Color::Green;
    printf("color = %d\n", static_cast<int>(col));

    // Vec2 template
    Vec2<float> v2;
    v2.x = 10.0f;
    v2.y = 20.0f;
    printf("v2 = (%g, %g)\n", v2.x, v2.y);

    // Inheritance
    Circle circle(5.0f);
    printf("circle.name = %s\n", circle.name());
    printf("circle.area = %g\n", circle.area());
    printf("circle.radius = %g\n", circle.radius);

    // Polymorphism via base pointer
    Shape* shape = &circle;
    printf("shape.name = %s\n", shape->name());
    printf("shape.area = %g\n", shape->area());

    // Multiple inheritance
    DrawableCircle dc(3.0f);
    printf("dc.name = %s\n", dc.name());
    printf("dc.area = %g\n", dc.area());
    printf("dc.radius = %g\n", dc.radius);

    return 0;
}

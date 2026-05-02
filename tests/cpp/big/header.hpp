#pragma once

namespace math {

// Scoped enum
enum class Color : int {
    Red = 0,
    Green = 1,
    Blue = 2,
};

// Template class
template<typename T>
struct Vec2 {
    T x;
    T y;
};

// Plain class with fields, methods, operators
class Vec3 {
public:
    float x;
    float y;
    float z;

    // Constructors
    Vec3();
    Vec3(float x, float y, float z);

    // Destructor
    ~Vec3();

    // Methods
    float length() const;
    void normalize();

    // Operators: arithmetic
    Vec3 operator+(const Vec3& other) const;
    Vec3 operator-(const Vec3& other) const;
    Vec3 operator*(float scalar) const;
    Vec3 operator-() const;  // unary negation

    // Operators: comparison
    bool operator==(const Vec3& other) const;
    bool operator!=(const Vec3& other) const;

    // Operators: subscript
    float& operator[](int index);
    const float& operator[](int index) const;

    // Operators: compound assignment
    Vec3& operator+=(const Vec3& other);
    Vec3& operator-=(const Vec3& other);
    Vec3& operator*=(float scalar);

    // Operators: copy and move assignment
    Vec3& operator=(const Vec3& other);
    Vec3& operator=(Vec3&& other);

    // Static method
    static Vec3 zero();
};

// Free function in namespace
float dot(const Vec3& a, const Vec3& b);
Vec3 cross(const Vec3& a, const Vec3& b);

// Template function
template<typename T>
T clamp(T value, T low, T high);

namespace nested {

// Inheritance: base
class Shape {
public:
    virtual ~Shape();
    virtual float area() const = 0;
    virtual const char* name() const;
};

// Inheritance: derived
class Circle : public Shape {
public:
    float radius;

    Circle(float radius);
    ~Circle() override;
    float area() const override;
    const char* name() const override;
};

// Multiple inheritance
class Drawable {
public:
    virtual ~Drawable();
    virtual void draw() const = 0;
};

class DrawableCircle : public Circle, public Drawable {
public:
    DrawableCircle(float radius);
    void draw() const override;
};

} // namespace nested
} // namespace math

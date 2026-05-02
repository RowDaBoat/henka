#include "test_cpp.hpp"
#include <cmath>
#include <cstring>

namespace math {

Vec3::Vec3() : x(0), y(0), z(0) {}
Vec3::Vec3(float x, float y, float z) : x(x), y(y), z(z) {}
Vec3::~Vec3() {}

float Vec3::length() const { return std::sqrt(x*x + y*y + z*z); }
void Vec3::normalize() {
    float len = length();
    if (len > 0) { x /= len; y /= len; z /= len; }
}

Vec3 Vec3::operator+(const Vec3& other) const { return {x + other.x, y + other.y, z + other.z}; }
Vec3 Vec3::operator-(const Vec3& other) const { return {x - other.x, y - other.y, z - other.z}; }
Vec3 Vec3::operator*(float scalar) const { return {x * scalar, y * scalar, z * scalar}; }
Vec3 Vec3::operator-() const { return {-x, -y, -z}; }

bool Vec3::operator==(const Vec3& other) const { return x == other.x && y == other.y && z == other.z; }
bool Vec3::operator!=(const Vec3& other) const { return !(*this == other); }

float& Vec3::operator[](int index) { return (&x)[index]; }
const float& Vec3::operator[](int index) const { return (&x)[index]; }

Vec3& Vec3::operator+=(const Vec3& other) { x += other.x; y += other.y; z += other.z; return *this; }
Vec3& Vec3::operator-=(const Vec3& other) { x -= other.x; y -= other.y; z -= other.z; return *this; }
Vec3& Vec3::operator*=(float scalar) { x *= scalar; y *= scalar; z *= scalar; return *this; }

Vec3& Vec3::operator=(const Vec3& other) { x = other.x; y = other.y; z = other.z; return *this; }
Vec3& Vec3::operator=(Vec3&& other) { x = other.x; y = other.y; z = other.z; return *this; }

Vec3 Vec3::zero() { return {0, 0, 0}; }

float dot(const Vec3& a, const Vec3& b) { return a.x*b.x + a.y*b.y + a.z*b.z; }
Vec3 cross(const Vec3& a, const Vec3& b) {
    return {a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x};
}

template<typename T>
T clamp(T value, T low, T high) {
    if (value < low) return low;
    if (value > high) return high;
    return value;
}
template float clamp<float>(float, float, float);
template int clamp<int>(int, int, int);

namespace nested {

Shape::~Shape() {}
const char* Shape::name() const { return "Shape"; }

Circle::Circle(float radius) : radius(radius) {}
Circle::~Circle() {}
float Circle::area() const { return 3.14159265f * radius * radius; }
const char* Circle::name() const { return "Circle"; }

Drawable::~Drawable() {}

DrawableCircle::DrawableCircle(float radius) : Circle(radius) {}
void DrawableCircle::draw() const {}

} // namespace nested
} // namespace math

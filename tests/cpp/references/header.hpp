struct Vec2 {
    float x;
    float y;
};

void normalize(Vec2 &v);
float dot(const Vec2 &a, const Vec2 &b);
Vec2 add(const Vec2 &&a, Vec2 &&b);

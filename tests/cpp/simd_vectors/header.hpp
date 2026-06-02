struct Vec4 {
    using Type = float __attribute__((__vector_size__(16)));

    float x;
    float y;
    float z;
    float w;
    Vec4() {}
    Vec4(float inX, float inY, float inZ, float inW);
    explicit Vec4(Type v);
};

union Data {
    int i;
    float f;
    char c;
};

struct Point {
    int x;
    int y;
};

union Value {
    int i;
    float f;
    struct Point p;
    void *raw;
};

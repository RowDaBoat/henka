struct Empty {};

struct Point {
    int x;
    int y;
};

struct Rect {
    struct Point origin;
    struct Point size;
};

struct Node {
    int value;
    struct Node * next;
};

struct Canvas {
    struct Rect * bounds;
    struct Point * cursor;
};

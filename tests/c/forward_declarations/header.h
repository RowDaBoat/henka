// Simple case
struct B;
struct A {
    struct B *b;
};
struct B {
    int x;
    int y;
};

// Interleaved case
struct D;
struct C {
    struct D *d;
};

void c(struct C a);

struct D {
    int v;
};

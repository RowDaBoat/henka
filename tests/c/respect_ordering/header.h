struct A {
    int x;
};

struct B {
    A *ptr;
    int count;
};

void render(B *list);

struct C {
    int x;
};

void use_c(struct C *c);

typedef unsigned short DrawIdx;

struct D {
    DrawIdx x;
};

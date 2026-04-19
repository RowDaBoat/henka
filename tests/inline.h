struct OuterA {
    struct InnerA { int a; };
    struct InnerA a;
};

struct OuterB {
    struct InnerB { int a; } a;
};

struct OuterC {
    struct { int a; } a;
};

struct OuterD {
    struct { int a; };
};

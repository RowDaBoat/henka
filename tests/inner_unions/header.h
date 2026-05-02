struct OuterA {
    union InnerA { int i; float f; };
    union InnerA a;
};

struct OuterB {
    union InnerB { int i; float f; } a;
};

struct OuterC {
    union { int i; float f; } a;
};

struct OuterD {
    union { int i; float f; };
};

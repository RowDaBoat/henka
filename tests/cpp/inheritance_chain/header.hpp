// A plain (non-virtual) inheritance chain. Each derived class must be able to
// name its base, which requires the base to be emitted as inheritable.
struct Base {
    int b;
};

struct Derived : public Base {
    int d;
};

struct MoreDerived : public Derived {
    int m;
};

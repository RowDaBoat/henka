struct Outer {
    struct Inner {
        int x;
    };
};

// A `using` alias whose target is namespace-qualified but resolves to the
// already-hoisted `Inner` type. henka must not emit a recursive `Inner = Inner`.
using Inner = Outer::Inner;

struct Outer {
    struct Inner {
        int x;
    };
};

// Don't emit a recursive `Inner = Inner`.
using Inner = Outer::Inner;

struct Widget {
    int v;
    // Mutable static singleton: emitted as `sInstance` getter + `sInstance=` setter.
    static Widget *sInstance;
    // const static member: skipped (compile-time constant, not assignable).
    static const int sMax;
};

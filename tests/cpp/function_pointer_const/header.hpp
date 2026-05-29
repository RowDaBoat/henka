struct ConstStruct {
    int field;
};

typedef void (*Callback)(ConstStruct const* param);

struct CallbackInfo {
    Callback callback;
};

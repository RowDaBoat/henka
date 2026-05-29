struct Device {
    int unused;
};

typedef void (*LostCallback)(Device const* device);

struct CallbackInfo {
    LostCallback callback;
};

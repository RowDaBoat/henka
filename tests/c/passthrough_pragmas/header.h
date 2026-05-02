#define EXPORT __attribute__((visibility("default")))
#define DEPRECATED __attribute__((deprecated))
#define PRAGMA_PUSH _Pragma("clang diagnostic push")

#define MULTILINE_ATTR \
    __attribute__((visibility("default"))) \
    __attribute__((deprecated))

EXPORT int exported_func(void);

// Simple literal
#define VERSION 42
#define NAME "hello"
#define PI_VAL 3.14f

// C operators
#define FLAGS_ALL (FLAG_A | FLAG_B)
#define INVERTED (~0U)
#define SHIFTED (1 << 8)
#define COMBINED (1 | (1 << 2) | (1 << 4))

// C cast expressions
#define NULL_HANDLE ((void*)0)
#define MAX_U32 ((uint32_t)-1)
#define TIMEOUT ((uint64_t)0xFFFFFFFFFFFFFFFFull)

// Struct initializers
#define EMPTY_STRUCT (MyStruct){0}
#define COLOR_RED (Color){255, 0, 0, 255}

// Function-like macros (henka skips these, but for reference)
#define MAKE_VERSION(a,b,c) ((a << 22) | (b << 12) | c)
#define CAST(T, val) ((T)(val))

// Macro referencing another macro
#define OLD_NAME NEW_NAME
#define ALIAS_CHAIN A_VALUE

// Compiler builtins
#define MY_FUNC __func__
#define MY_FILE __FILE__
#define BYTE_ORDER __BYTE_ORDER__

// Visibility/calling convention
#define EXPORT __attribute__((visibility("default")))
#define APIENTRY __attribute__((stdcall))
#define DEPRECATED __attribute__((deprecated))

// Compound literals (raylib-style)
#define CLITERAL(type) (type)
#define WHITE CLITERAL(Color){255, 255, 255, 255}

// Integer suffix variants
#define VAL_ULL 0xFFFFFFFFFFFFFFFFull
#define VAL_LLU 1llu
#define VAL_U 42U
#define VAL_F 3.14f

// Macro alias to function-like macro call
#define COMPILED_VER MAKE_VERSION(1, 2, 3)

// C type as value
#define MY_FLOAT float
#define MY_TYPE_SIZE sizeof(int)

// Ifdef-guarded (not visible to clang without defines)
#ifdef FEATURE_X
#define FEATURE_VAL 1
#endif

// Empty/flag macros (no value)
#define HAS_FEATURE

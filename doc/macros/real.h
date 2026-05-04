// Real-world macro patterns from tested libraries

// === flecs patterns ===
#include <stdint.h>
#include <stddef.h>

typedef uint64_t ecs_flags64_t;
typedef uint32_t ecs_flags32_t;
typedef uint16_t ecs_flags16_t;
typedef uint8_t  ecs_flags8_t;

// ECS_CAST: C cast wrapper
#define ECS_CAST(T, V) ((T)(V))

// Bit flags with casts and shifts
#define ECS_ID_FLAGS_MASK   (0xFFull << 60)
#define ECS_ENTITY_MASK     (0xFFFFFFFFull)
#define ECS_GENERATION_MASK (0xFFFFull << 32)
#define ECS_COMPONENT_MASK  (~ECS_ID_FLAGS_MASK)

// llu suffix variant
#define EcsSelf       (1llu << 63)
#define EcsUp         (1llu << 62)

// ECS_CAST in values
#define ECS_TYPE_HOOK_CTOR          ECS_CAST(ecs_flags32_t, 1u << 0)
#define ECS_TYPE_HOOK_DTOR          ECS_CAST(ecs_flags32_t, 1u << 1)
#define ECS_TYPE_HOOK_COPY          ECS_CAST(ecs_flags32_t, 1u << 2)
#define ECS_TYPE_HOOKS              (ECS_TYPE_HOOK_CTOR | ECS_TYPE_HOOK_DTOR | ECS_TYPE_HOOK_COPY)

// Struct initializer
typedef struct { int x; } ecs_strbuf_t;
#define ECS_STRBUF_INIT (ecs_strbuf_t){0}

// Function-like macro in value
#define ECS_SIZEOF(T) ((int64_t)sizeof(T))
#define ECS_ALIGN(size, alignment) (((size) + (alignment) - 1) & ~((alignment) - 1))
#define FLECS_STACK_PAGE_OFFSET ECS_ALIGN(ECS_SIZEOF(int), 16)

// Macro aliasing another identifier
#define ECS_DECLARE extern
#define ECS_ENTITY_DECLARE ECS_DECLARE
#define ecs_pair_relation ecs_pair_first

// Type as macro value
#define ecs_float_t float

// === godot-cpp pattern ===
// Massive macro that expands to inline class methods
#define CLASSDB_SINGLETON_FORWARD_METHODS \
    static int get_class_list() { return 0; } \
    static int get_parent_class(const char* name) { return 0; } \
    static int class_exists(const char* name) { return 0; }

// === SDL2 patterns ===
// C cast in value
#define SDL_MAX_SINT8  ((int8_t)0x7F)
#define SDL_MIN_SINT8  ((int8_t)(~0x7F))
#define SDL_MAX_UINT32 ((uint32_t)0xFFFFFFFFu)
#define SDL_MUTEX_MAXWAIT (~(uint32_t)0)

// Compiler builtins
#define SDL_BYTEORDER __BYTE_ORDER__
#define SDL_FUNCTION  __func__

// Function-like macro call in value
#define SDL_VERSIONNUM(X, Y, Z) ((X)*1000 + (Y)*100 + (Z))
#define SDL_COMPILEDVERSION SDL_VERSIONNUM(2, 28, 0)

// Macro calling another macro with parens
#define SDL_BUTTON(X) (1 << ((X)-1))
#define SDL_BUTTON_LMASK SDL_BUTTON(1)

// === raylib patterns ===
// Compound literal color
typedef struct { unsigned char r, g, b, a; } Color;
#define CLITERAL(type) (type)
#define WHITE CLITERAL(Color){255, 255, 255, 255}
#define RED   CLITERAL(Color){230, 41, 55, 255}

// Float suffix
#define PI 3.14159265358979323846f
#define DEG2RAD (PI/180.0f)

// Deprecated alias to function
void GetScreenToWorldRay(void);
#define GetMouseRay GetScreenToWorldRay

// === OpenGL patterns ===
// ull suffix on hex
#define GL_TIMEOUT_IGNORED 0xFFFFFFFFFFFFFFFFull

// Calling convention
#define APIENTRY
#define GLAPIENTRY APIENTRY
#define APIENTRYP APIENTRY *

// === Vulkan patterns ===
// Function-like macro for version packing
#define VK_MAKE_API_VERSION(variant, major, minor, patch) \
    ((((uint32_t)(variant)) << 29) | (((uint32_t)(major)) << 22) | (((uint32_t)(minor)) << 12) | ((uint32_t)(patch)))
#define VK_API_VERSION_1_0 VK_MAKE_API_VERSION(0, 1, 0, 0)

// Null handle via cast
#define VK_NULL_HANDLE ((void*)0)

// === clay patterns ===
// Packed enum with underlying type
#define CLAY_PACKED_ENUM enum : uint8_t

// Struct initializer (empty/zero)
#define CLAY_DEFAULT_STRUCT {0}

// Designated initializer in compound literal
typedef struct { float minMax[2]; } Clay_SizingMinMax;
typedef struct { union { Clay_SizingMinMax minMax; float percent; } size; int type; } Clay_SizingAxis;
#define CLAY_SIZING_FIT_IMPL(...) (Clay_SizingAxis){ .size = { .minMax = { __VA_ARGS__ } }, .type = 0 }
#define CLAY_SIZING_PERCENT_IMPL(p) (Clay_SizingAxis){ .size = { .percent = (p) }, .type = 3 }

// Variadic pass-through
#define CLAY_TEXT_CONFIG(...) __VA_ARGS__

// Comma operator sequencing
void Clay_Open(void);
void Clay_Close(void);
#define CLAY_ELEMENT_IMPL (Clay_Open(), Clay_Close(), 0)

// Compound literal with member access
typedef struct { int wrapped; } Clay_Wrapper;
#define CLAY_CONFIG_WRAPPER(type, ...) ((Clay_Wrapper){ __VA_ARGS__ }).wrapped

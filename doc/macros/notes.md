# Macro Handling TODO

libclang gives us raw tokens per macro — no parse tree, no type info, no expansion.
`clang_Cursor_Evaluate` only works for macros that resolve to a single constant in a TU context (rarely works in practice).
`clang_Cursor_isMacroFunctionLike` correctly distinguishes object-like from function-like macros.

The token stream is flat: identifiers, operators, literals, punctuation — all as strings.
A mini C expression parser operating on the token stream would fix most macro failures.


## Token patterns observed

### 1. Single literal value
`#define VERSION 42` → tokens: `["VERSION", "42"]`
`#define NAME "hello"` → tokens: `["NAME", "\"hello\""]`
Currently handled. Works.

### 2. Single identifier alias
`#define OLD_NAME NEW_NAME` → tokens: `["OLD_NAME", "NEW_NAME"]`
`#define ecs_pair_relation ecs_pair_first` → tokens: `["ecs_pair_relation", "ecs_pair_first"]`
Currently handled as `const OLD_NAME = NEW_NAME`. Breaks when the target is defined later (forward reference).

### 3. Parenthesized expression with C operators
`#define SHIFTED (1 << 8)` → tokens: `["SHIFTED", "(", "1", "<<", "8", ")"]`
`#define FLAGS_ALL (FLAG_A | FLAG_B)` → tokens: `["FLAGS_ALL", "(", "FLAG_A", "|", "FLAG_B", ")"]`
Currently joins tokens with spaces → `( 1 << 8 )`. Needs operator replacement (`<<`→`shl`, `|`→`or`, etc.) in value mapper.

### 4. C cast expression
`#define SDL_MAX_SINT8 ((int8_t)0x7F)` → tokens: `["SDL_MAX_SINT8", "(", "(", "int8_t", ")", "0x7F", ")"]`
`#define VK_NULL_HANDLE ((void*)0)` → tokens: `["VK_NULL_HANDLE", "(", "(", "void", "*", ")", "0", ")"]`
Pattern: `( ( TYPE ) VALUE )` — two open parens, type name, close paren, value, close paren.
Not handled. The C cast should be stripped and the value emitted directly, with optional type annotation.

### 5. C cast via macro
`#define ECS_TYPE_HOOK_CTOR ECS_CAST(ecs_flags32_t, 1u << 0)` → tokens: `["ECS_TYPE_HOOK_CTOR", "ECS_CAST", "(", "ecs_flags32_t", ",", "1u", "<<", "0", ")"]`
Pattern: function-like macro call in object-like macro value.
Not handled. Need to recognize known cast macros and extract the value part.

### 6. Struct/compound literal initializer
`#define ECS_STRBUF_INIT (ecs_strbuf_t){0}` → tokens: `["ECS_STRBUF_INIT", "(", "ecs_strbuf_t", ")", "{", "0", "}"]`
`#define WHITE CLITERAL(Color){255, 255, 255, 255}` → tokens: `["WHITE", "CLITERAL", "(", "Color", ")", "{", "255", ",", "255", ",", "255", ",", "255", "}"]`
Pattern: `( TYPE ) { VALUES }` or `MACRO ( TYPE ) { VALUES }`.
Not handled. Should emit as `Type(field: val, ...)` but needs struct field names.

### 7. Function-like macro call in value
`#define SDL_COMPILEDVERSION SDL_VERSIONNUM(2, 28, 0)` → tokens: `["SDL_COMPILEDVERSION", "SDL_VERSIONNUM", "(", "2", ",", "28", ",", "0", ")"]`
`#define SDL_BUTTON_LMASK SDL_BUTTON(1)` → tokens: `["SDL_BUTTON_LMASK", "SDL_BUTTON", "(", "1", ")"]`
Pattern: `IDENTIFIER ( ARGS )` where IDENTIFIER is a known function-like macro.
Not handled. Could emit as Nim template/proc call if the function-like macro is also converted.

### 8. Integer literal suffixes
`0xFFull`, `1llu`, `42U`, `0xFFFFFFFFu`, `200809L`
Pattern: number token with trailing letters.
Partially handled via value mapper. Needs comprehensive stripping: `ull`/`ULL`/`llu`/`LLU`→`'u64`, `u`/`U`→`'u32`, `l`/`L`→ strip, `f`/`F`→ strip.

### 9. Float suffix
`3.14f`, `180.0f`, `1000.0F`
Pattern: float literal with `f`/`F` suffix.
Not handled in henka defaults. User value mapper strips them case by case.

### 10. Compiler builtins
`#define MY_FUNC __func__` → tokens: `["MY_FUNC", "__func__"]`
`#define BYTE_ORDER __BYTE_ORDER__` → tokens: `["BYTE_ORDER", "__BYTE_ORDER__"]`
Pattern: single identifier starting with `__`.
Not handled. Should either skip or map to Nim equivalents.

### 11. Visibility/calling convention attributes
`#define EXPORT __attribute__((visibility("default")))` → tokens: `["EXPORT", "__attribute__", "(", "(", "visibility", "(", "\"default\"", ")", ")", ")"]`
Pattern: first value token is `__attribute__` or `__declspec`.
Currently handled — emitted as `sPassthrough` (comment).

### 12. Empty/flag macro
`#define HAS_FEATURE` → tokens: `["HAS_FEATURE"]` (1 token = just the name)
Currently handled — henka skips macros with ≤1 token.

### 13. Type name as value
`#define ecs_float_t float` → tokens: `["ecs_float_t", "float"]`
Pattern: single identifier that is a C type keyword.
Currently emitted as `const ecs_float_t = float` which fails — `float` is a Nim type, not a value.
Should emit as `type ecs_float_t = cfloat` (type alias).

### 14. C code block (godot-cpp CLASSDB)
`#define CLASSDB_SINGLETON_FORWARD_METHODS static int get_class_list() { ... }` → tokens contain `static`, `return`, `;`, `{`, `}`.
Pattern: tokens contain C statement keywords and semicolons.
Currently emitted as giant `const` with raw C code. Should be skipped or emitted as passthrough comment.

### 15. Pointer type alias
`#define APIENTRYP APIENTRY *` → tokens: `["APIENTRYP", "APIENTRY", "*"]`
Pattern: identifier followed by `*`.
Currently emitted as `const APIENTRYP = APIENTRY *` which is invalid Nim.
Should be skipped (calling convention detail).

### 16. Bitwise NOT with cast
`#define SDL_MUTEX_MAXWAIT (~(uint32_t)0)` → tokens: `["SDL_MUTEX_MAXWAIT", "(", "~", "(", "uint32_t", ")", "0", ")"]`
Pattern: `~ ( TYPE ) VALUE` — bitwise not of a cast.
Not handled. Should resolve to `not 0'u32` or `high(uint32)`.

### 17. Designated initializer in compound literal
`#define CLAY_SIZING_FIT(...) (Clay_SizingAxis){ .size = { .minMax = { __VA_ARGS__ } }, .type = 0 }`
Pattern: compound literal with `.field = value` syntax inside braces.
Not handled. C99 designated initializers have no direct Nim equivalent in macro context.
Would need to generate a Nim proc/template that constructs the object with named fields.

### 18. Enum with explicit underlying type
`#define CLAY_PACKED_ENUM enum : uint8_t`
Pattern: `enum` keyword followed by `: type`.
Not handled. Should map to Nim `{.size: sizeof(uint8).}` on the enum or a `distinct uint8`.

### 19. Comma operator sequencing
`#define CLAY_ELEMENT (Clay_Open(), Clay_Close(), 0)`
Pattern: `( expr , expr , expr )` — C comma operator, evaluates all, returns last.
Not handled. Would need to generate a Nim block/template with multiple statements returning the last value.

### 20. Compound literal with member access
`#define CLAY_CONFIG_WRAPPER(type, ...) ((Clay_Wrapper){ __VA_ARGS__ }).wrapped`
Pattern: compound literal followed by `.member`.
Not handled. Combines struct initializer (#6) with field access.


## Libraries tested and macro issues encountered

| Library   | Macro issues |
|-----------|-------------|
| GLFW      | C operators (#3), calling convention aliases (#15), Nim case collisions |
| stb       | `extern` as value (#2), compiler builtins (#10) |
| raylib    | Compound literals (#6), float suffixes (#9), deprecated aliases (#2), `va_list` |
| OpenGL    | ull suffixes (#8), calling convention (#15), Nim case collisions |
| Vulkan    | Function-like calls in values (#7), C casts (#4), ull suffixes (#8), null pointer (#4) |
| SDL2      | C casts (#4), function-like calls (#7), compiler builtins (#10), struct initializers (#6) |
| flecs     | ECS_CAST macro (#5), struct initializers (#6), function-like chains (#7), llu suffixes (#8), type-as-value (#13) |
| godot-cpp | C code blocks (#14) |
| dearimgui | Forward references (not macro-related), C++ struct methods |
| clay      | Designated initializers (#17), packed enums (#18), comma operator (#19), member access on literal (#20), double underscore in types |


## Reference files
- `doc/macros/patterns.h` — synthetic test patterns
- `doc/macros/real.h` — real-world patterns from all tested libraries
- `doc/macros/inspect.nim` — token inspection tool (run from henka root)

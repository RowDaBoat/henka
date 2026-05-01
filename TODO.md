# Henka TODO


## v1 feature parity (Missing features from butcher)
- [x] Large uint64 literal suffix — values exceeding int32 range need `'u64` suffix in const declarations (fixed in slate codegen)
- [x] Union pragma — `{.union.}` for C union types (slate codegen renders TypeObject.keyword as pragma, henka converter sets keyword + dispatches CXCursor_UnionDecl)
- [x] Duplicate enum value handling — not needed: C enums are generated as `cint` alias + `const` values, which naturally allow duplicates
- [x] `sanitizer` callback — separate `Sanitizer` callback runs after renamer in `addRenamed`. Default dedup-underscores and adds `priv` prefix for `_` names. User can override or compose.
- [x] Relative header paths in pragmas — replaced `includeDir` with `rootDir` derived from first input file's parent. `headerPragma` computes `relativePath(headerFile, rootDir)`
- [x] Nested structs/unions/enums — named inner types emitted as standalone, unnamed get synthetic `ParentName_unnamedN`, anonymous flatten into parent
- [x] Variadic function support — detect `clang_Cursor_isVariadic` and emit `{.varargs.}` pragma
- [x] Two-pass generation / forward declarations — full definitions replace incomplete types in-place via `seenStructs` table keyed by type ID
- [x] Fix unnamed structs — unnamed fields get synthetic `ParentName_unnamedN` types, anonymous members flatten fields into parent
- [ ] CLI entry point with proper argument parsing (`--help`, `--clangargs`, `--astout`, `--nimout`, etc.) using Cliquet.


## Other v2 tasks
- [ ] Better cint enum ergonomics — current `cint` alias + `const` works but loses type safety and IDE autocomplete
- [ ] so/dll/dylib
- [ ] write DSL for AST


## Converter Bugs
- [ ] Generated libclang bindings are missing CXTranslationUnit parse option constants (C macros expanding to integer literals — converter skips them as function-like or unknown expansions)
- [ ] `SingleFileParse` breaks anonymous typedef structs — types resolve to `cint` instead of proper struct types (only affects C headers with `typedef struct { ... } Name;` pattern)
- [ ] Godot-cpp: 3 `UNSUPPORTED_0` from `CXType_Invalid` on template edge cases (`MIN`, `MAX`, `CLAMP` with `decltype(auto)` return)
- [ ] Godot-cpp: template specializations in parameter types (`Ref<InputEvent>`) come through as raw text instead of resolved Nim types
- [ ] `dynlib` mode still needs `header:` on `bycopy` types with `importc` — should generate pure Nim structs without `importc` to eliminate header dependency entirely
- [ ] Missing `long double` → `clongdouble` mapping (`CXType_LongDouble` = 23 not handled)
- [ ] `IncompleteArray` maps to `ptr T` instead of `UncheckedArray[T]` — butcher used `UncheckedArray` which is more idiomatic Nim for C's `T[]` parameters
- [ ] `volatile`/`restrict` qualifier stripping — libclang usually resolves these but may not always
- [x] Standard C macro values (`UINT32_MAX`, `SIZE_MAX`, `NAN`, etc.) not mapped to Nim equivalents — added `ValueMapper` callback with `defaultValueMapper`
- [x] Type resolver (`toObject` in types.nim) calls `conv.renamer` directly, bypassing `addRenamed` and the sanitizer — produces unsanitized names like `struct__CXChildVisitResult` with double underscores


## Architecture
- [ ] Move multi-module rendering logic into slate (currently hardcoded in generator.nim)
- [ ] The `passthrough` pragma for `__attribute__`/`_Pragma` macros should emit proper `{.pragma.}` declarations instead of comments
- [ ] Support `{.compile.}` pragma for embedding C/C++ source alongside bindings
- [ ] Per-module statement chain tracking for true multi-module output (currently all statements chain together, split by module.body)


## Testing
- [ ] Test with SDL2/SDL3 headers
- [ ] Test with Vulkan headers
- [ ] Test with OpenGL headers
- [ ] Test with raylib headers
- [ ] Test with GLFW headers
- [ ] Test with stb_image and other stb headers
- [ ] Test with godot-cpp: verify generated bindings compile against Godot engine
- [x] Test with libclang: self-hosting loop (generate api.nim → compile with it → regenerate → verify identical output)
- [ ] Test with a large C++ library (Qt, LLVM, Boost) to stress-test template handling


## Documentation
- [ ] Write user-facing docs for callback APIs (renamer, symbolFilter, symbolOverride, typeMapper, pragmaOverride, etc.)
- [ ] Document the C vs C++ detection and `--cpp` flag behavior
- [ ] Document `LinkMode.header` vs `LinkMode.dynlib` tradeoffs
- [ ] Document `SingleFileParse` behavior and when to use it


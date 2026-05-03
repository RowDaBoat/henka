# Henka TODO

## v1 feature parity (Missing features from butcher)
- [x] Large uint64 literal suffix — values exceeding int32 range need `'u64` suffix in const declarations (fixed in slate codegen)
- [x] Union pragma — `{.union.}` for C union types (slate codegen renders TypeObject.keyword as pragma, henka converter sets keyword + dispatches CXCursor_UnionDecl)
- [x] Duplicate enum value handling — not needed: C enums are generated as `cint` alias + `const` values, which naturally allow duplicates
- [x] `sanitizer` callback — separate `Sanitizer` callback runs after renamer in `addRenamed`. Default dedup-underscores and adds `priv` prefix for `_` names. User can override or compose.
- [x] Relative header paths in pragmas — replaced `includeDir` with `rootDir` derived from first input file's parent. `headerPragma` computes `relativePath(headerFile, rootDir)`
- [x] Nested structs/unions/enums — named inner types emitted as standalone, unnamed get synthetic `ParentName_unnamedN`, anonymous flatten into parent
- [x] Variadic function support — detect `clang_Cursor_isVariadic` and emit `{.varargs.}` pragma
- [x] Forward declarations — full definitions replace incomplete types in-place via `seenStructs` table keyed by type ID and module ID
- [x] Forward declaration replacement for C++ class templates — `toClassTemplate` now replaces incomplete types with full definitions, same as `toObject`
- [x] Multi-module source buffer corruption — replacement types now switch `conv.module` to original module before `collectFields` and `buildObjectType`, so all source writes go to the correct module buffer
- [x] Seq reallocation bug in type replacement — `types[id] = buildType()` could corrupt `types[id]` if `buildType` grew the seq. Fixed by evaluating RHS into a local before assigning
- [x] Comments attached to statements — doc comments now use the `comment` field on `StatementType`/`StatementProcedure` etc. instead of separate `sComment` statement nodes. Prerequisite for statement chain reordering
- [x] `seenSymbols` blocking forward declaration replacement for `ClassDecl`/`ClassTemplate` — added to exclusion set so second visits reach `toClass`/`toClassTemplate`
- [x] Two-pass generation / statement chain reorder — types now emit to a separate chain from procs/consts, stitched together at render time. Types always appear first in output. Fixes dearimgui `ImVector` ordering
- [x] Duplicate type alias from typedef + enum — dearimgui `typedef int ImGuiWindowFlags;` and `enum ImGuiWindowFlags_ {}` both produce `ImGuiWindowFlags` alias. Fixed with `seenTypedefs` set tracking sanitized Nim names
- [x] Fix unnamed structs — unnamed fields get synthetic `ParentName_unnamedN` types, anonymous members flatten fields into parent
- [x] CLI entry point with proper argument parsing (`--help`, `--clangargs`, `--astout`, `--nimout`, etc.) using Cliquet.
- [x] Remove `clang/api.nim` from git and make `clang/minimal.nim` the default — flip the `when defined` switch so minimal is imported by default and `api.nim` is only used when `clang_selfhosted` is defined. Selfhost regenerates `api.nim` on demand.

## v2 Converter Bugs
- [x] Generated libclang bindings are missing CXTranslationUnit parse option constants — resolved: they're enum values, not macros; selfhost generates them correctly
- [x] `SingleFileParse` breaks anonymous typedef structs — clang limitation: `SingleFileParse` makes clang resolve unseen anonymous typedef structs as `int`. Unfixable; use `singleFileParse = false` for headers with this pattern
- [x] `dynlib` mode still needs `header:` on `bycopy` types with `importc` — already fixed: dynlib mode emits pure `{.bycopy.}` structs without `importc` or `header`
- [x] Missing `long double` → `clongdouble` mapping — added `CXType_LongDouble` to primitives set and case
- [x] `IncompleteArray` maps to `ptr T` instead of `UncheckedArray[T]` — now uses `tArray` with `name = "UncheckedArray"`
- [x] `volatile`/`restrict` qualifier stripping — libclang already resolves these, no henka changes needed
- [x] Standard C macro values (`UINT32_MAX`, `SIZE_MAX`, `NAN`, etc.) not mapped to Nim equivalents — added `ValueMapper` callback with `defaultValueMapper`
- [x] Type resolver (`toObject` in types.nim) calls `conv.renamer` directly, bypassing `addRenamed` and the sanitizer — produces unsanitized names like `struct__CXChildVisitResult` with double underscores
- [x] `toEnum` also bypassed sanitizer — `conv.renamer(EnumType, name)` used directly without `addRenamed`, producing trailing underscores (e.g. `enum_ImGuiWindowFlags_`)
- [x] The `passthrough` pragma for `__attribute__`/`_Pragma` macros — now emits `sPassthrough` statements instead of `sComment`, distinguishable from doc comments by downstream tooling
- [x] Godot-cpp: `UNSUPPORTED_118` from `CXType_Auto` on template edge cases (`MIN`, `MAX`, `CLAMP`) — mapped `CXType_Auto` to `auto` primitive
- [x] Godot-cpp: template specializations in parameter types (`Ref<InputEvent>`) — hack: `add_primitive` replaces `<>`→`[]` in type names. Works but should use proper generic type AST nodes


## Other v2 tasks
- [x] Per-module statement chain tracking — chain pointers reset and stitched per module in generator loop
- [x] `size_t` resolves to `cint` — was missing `#include <stddef.h>` in test header. clang needs the typedef visible to report `size_t` correctly.
- [x] C++ struct methods — C++ `StructDecl` now routes through `toClass` with `defaultPublic=true`. Forward declaration replacement in `toClass`. Nested C++ structs/classes/enums hoisted via recursive visitor.
- [x] Nim case-insensitive name collisions — caller handles via `renamer`/`symbolFilter`. `symbolFilter` now supports `EnumValue` kind for filtering individual enum members.
- [x] C operators in macro values — `|`→`or`, `&`→`and`, `~`→`not`, `<<`→`shl`, `>>`→`shr` now in `defaultValueMapper`
- [x] Move multi-module rendering logic into slate — `slate.codegen.nim(ast)` renders all modules, returns Output
- [ ] write DSL for AST
- [x] Proper generic type references in AST
  - [x] `TypePrimitive.instantiation` field added to astTF spec (v0.9.7)
  - [x] `add_primitive` now parses `<>` and creates expression chain for type arguments
  - [x] Simple and multi-arg templates work: `Ref[int]`, `Map[int, float]`
  - [x] Nested templates: `Vector<Ref<int>>` → `Vector[Ref[int]]` — expression name uses `<>`→`[]` string replacement, not recursive `instantiation` chains
  - [x] Template typedef alias ordering — fixed by putting all `sType` statements in one chain (types → aliases → others). All type statements stay in one `type` block so Nim forward references work.
  - [x] Template instantiation arg types not resolved through type system — fixed by using `clang_Type_getNumTemplateArguments` / `clang_Type_getTemplateArgumentAsType` in `toObject` to get actual `CXType` values and run them through `convertType`. `int`→`cint`, `float`→`cfloat` etc.
  - [x] `toAlias` space-in-angle-brackets — `typedef Map<int, Ref<float>>` was falling through to `incompleteStruct` because `' ' in elabName` didn't skip spaces inside `<>`. Fixed with `'<' notin elabName` guard.
- [x] C++ reference semantics in bindings
  - [x] `T&` (mutable lvalue ref) → `var T` via `mutable: true` on type
  - [x] `T&&` (rvalue ref) → `sink T` via `keyword: "sink"` on primitive type
  - [x] `const T&` → `T` (flattened, const stripped)
  - [x] `const T&&` → `T` (flattened, const stripped)
- [ ] Macro expression parser — libclang only gives raw tokens for macros, no parse tree. Need a mini C expression parser to handle casts `(Type)val`, struct initializers `{0}`, function-like calls `FOO(a,b)`. Would fix most remaining macro-related failures (SDL, stb, flecs, raylib). Operators and literal suffixes now handled by `defaultValueMapper`.


## Ergonomics (v2)
- [ ] Better cint enum ergonomics — current `cint` alias + `const` works but loses type safety and IDE autocomplete
- [ ] Support `{.compile.}` pragma for embedding C/C++ source alongside bindings
- [ ] so/dll/dylib auto-resolution (current solution: `{.strdefine.}`)
- [x] Potentially unify renamer/symbolOverride/unnamedFieldNamer into a single callback or pipeline (different goals entirely)


## Testing
- [x] Test with libclang: self-hosting loop (generate api.nim → compile with it → regenerate → verify identical output)
- [x] Test with GLFW headers — 514 lines, passes `nim check`. `GLFW_CURSOR` const filtered to avoid collision with `GLFWcursor` type.
- [ ] Test with stb_image and other stb headers (20/20 pass `nim check` with user filters)
  - [x] stb_image — generates, compiles, runs
  - [x] Double underscores in type references — fixed via sanitizer in `toObject` else branch
  - [x] `extern` macro values — filtered via user `symbolFilter` (`EXTERN`/`DEC`/`DECL` patterns)
  - [x] Macro alias chains (stb_ds) — filtered via user `symbolFilter` (`stbds_*` and short aliases)
  - [x] Type-as-value macros (stb_textedit, stb_truetype) — filtered via user `symbolFilter`
  - [ ] Macro alias chains — `stbds_arrlen` etc. are function-like macros that need the macro expression parser to convert properly
  - [ ] Type-as-value macros — `#define stbtt_vertex_type short` should emit a type alias, needs macro expression parser
  - [ ] `extern` as macro value — `#define STBHW_EXTERN extern` should be skipped or converted to a pragma, needs macro expression parser
- [x] Test with OpenGL headers — gl.h (8714), glext.h (7771), glcorearb.h (3696) all pass `nim check` (20K lines total). Requires user callbacks for: type name collisions (`_t` suffix), khronos type mappings, calling convention macro filtering
- [x] Test with raylib headers — 1238 lines, passes `nim check`, compiles and links against libraylib.a
  - [x] `va_list` type mapping — now in `standardTypeMappings` (`"va_list"` → `"pointer"`)
  - [x] C operators, literal suffixes, float suffix `f` — now in `defaultValueMapper`
  - [x] Deprecated alias macros — filtered via user `symbolFilter`
  - [x] Visibility macros (`RLAPI`, `RMAPI`) — filtered via user `symbolFilter`
  - [ ] Color macro constants (`CLITERAL(Color){...}`) need manual override — C compound literals have no Nim equivalent
- [x] Test with Vulkan headers — 13901 lines, passes `nim check`
  - [x] Union typedef aliases — fixed by `union ` prefix strip in `toAlias`
  - [x] Video codec types — resolved with stub types prepended to output
  - [x] Deprecated macro aliases — skipped via `symbolFilter`
  - [x] Nim case-insensitive collisions (enum value vs type alias) — skipped via user `symbolFilter` with `EnumValue` kind
  - [x] Khronos type mappings, calling convention macros — handled by user callbacks
  - [x] C literal suffixes — now in `defaultValueMapper` via `stripCSuffix`
- [ ] Test with SDL2/SDL3 headers — 2989 lines, 8 errors (all from one C cast expression on line 2)
  - [x] Union typedef forward declaration issues — fixed by `union ` prefix strip in `toAlias`
  - [x] C operators and literal suffixes — now in `defaultValueMapper`
  - [x] Proc-vs-type name collisions — `SDL_threadID` remapped, `SDL_QUIT` enum value filtered via `symbolFilter` (`EnumValue` kind)
  - [x] Unnamed struct fields in unions — handled via synthetic names and post-processing
  - [ ] C cast expressions in macro values (`((Sint8) 0x7F)`) — needs macro expression parser
  - [ ] Function-like macro calls in const values (`SDL_VERSIONNUM(...)`, `SDL_BUTTON(...)`) — not currently erroring (skipped or resolved by clang) but not properly converted
  - [ ] Compiler builtin macros (`__func__`, `__BYTE_ORDER`, `__GNUC__`) — not currently erroring but not properly handled
- [x] Test with dearimgui — 1847 lines, passes `nim check`, 661 procs, 206 struct methods
  - [x] Template type resolution — fixed by using clang Type API for template args, types now resolve through `convertType`
  - [x] Type block ordering — all type statements in one block, const aliases separate. Typedefs like `ImU32 = cuint` no longer break forward references.
  - [x] `ImVector<T>*` fields now resolve to proper generic types — fixed by clang Type API for template args
  - [x] 5 opaque forward declarations (`ImDrawListSharedData`, `ImFontAtlasBuilder`, `ImFontLoader`, `ImGuiContext`, `ImNewWrapper`) — correctly emit as `{.incompleteStruct.}` objects, used as `ptr` everywhere
- [ ] Test with godot-cpp: 1055/1056 files generate without crashing, but each file re-emits all included symbols (~902K lines for 1056 files). Needs cross-file import tracking and symbol origin filtering to produce usable multi-file output. Also `CLASSDB_SINGLETON_FORWARD_METHODS` macro expands to ~6KB raw C++ in 952 files.
- [ ] Test with flecs — 2945 lines, 130 errors
  - [x] `ptr void` — fixed: `toPointer` now uses `clang_getCanonicalType` to resolve typedef-to-void pointers as `pointer`
  - [x] `llu`/`ull` suffix variants on hex literals — now handled by `stripCSuffix` in `defaultValueMapper`
  - [ ] `let` symbol requires initialization — 130 errors: consts with macro values that couldn't be parsed emit as `let` with no value
  - [ ] `ECS_CAST(type, value)` macro in const values — C cast expression
  - [ ] C struct initializer macros — `(ecs_strbuf_t){0}`, `ECS_HTTP_REPLY_INIT`, etc.
  - [ ] Function-like macro calls in values — `ecs_id(...)`, `ECS_SIZEOF(...)`, `ECS_ALIGN(...)`
  - [ ] Macro alias chains — `ECS_TAG_DECLARE = ECS_DECLARE`, `ecs_dbg = ecs_dbg_1`
- [x] Test with qu3e (C++ physics) — 358 lines, passes `nim check`. Only `Q3_SLEEP_ANGULAR` filtered (macro references non-const variable `q3PI`)
  - [x] `FLT_MAX` → `high(cfloat)` — added `FLT_MAX`, `FLT_MIN`, `DBL_MAX`, `DBL_MIN` to `standardValueMappings`
  - [x] `r32(literal)` type conversions — work natively as Nim type conversions since `r32` is a typedef alias
- [ ] Test with clay — 455 lines, passes `nim check`
  - [x] Double underscore type references — fixed via sanitizer in `toObject` else branch
  - [x] `Clay_RenderData` redefinition — `typedef union` same-name skip was missing `union ` prefix strip in `toAlias`
  - [ ] Macro-heavy API — designated initializers, comma operators, function-like macros. Most are correctly skipped but not converted.
- [x] Test with XCB headers — 3635 lines, passes `nim check`
  - [x] `L`/`U` suffix on integer literals — fixed via `stripCSuffix` in `defaultValueMapper`
- [x] Test with X11 headers — 1692 lines, passes `nim check`
  - [x] `L`/`U` suffix on integer literals — fixed via `stripCSuffix`
  - [x] `<<`/`>>` operators — fixed via `shl`/`shr` replacement in `defaultValueMapper`
  - [x] Unnamed struct type reference — handled via user `typeMapper` mapping to `pointer`
  - [x] `include`/`Utf32Char` identifiers — filtered/mapped via user callbacks
  - [x] `wchar_t` mapped to `cuint` in `standardTypeMappings`
- [x] Test with wgvk (WebGPU/Vulkan) — 1877 lines, passes `nim check`
- [ ] Test with a large C++ library (Qt, LLVM, Boost) to stress-test template handling


## Documentation
- [ ] Write user-facing docs for callback APIs (renamer, symbolFilter, symbolOverride, typeMapper, pragmaOverride, etc.)
- [ ] Document the C vs C++ detection and `--cpp` flag behavior
- [ ] Document `LinkMode.header` vs `LinkMode.dynlib` tradeoffs
- [ ] Document `SingleFileParse` behavior and when to use it


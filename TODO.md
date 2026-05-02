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
- [ ] Macro expression parser — libclang only gives raw tokens for macros, no parse tree. Need a mini C expression parser to handle casts `(Type)val`, struct initializers `{0}`, function-like calls `FOO(a,b)`, and operator expressions. Would fix most macro-related failures across all tested headers
- [ ] Proper generic type references in AST — `Ref<Animation>` currently hacked as `Ref[Animation]` string literal in primitive name; should parse into generic type nodes with proper type arguments
- [ ] C operators in macro values — `|`, `&`, `~` in macro expansions need rewriting to Nim `or`, `and`, `not` (currently requires user `valueMapper`)
- [ ] Nim case-insensitive name collisions — `GLFW_CURSOR` (const) vs `GLFWcursor` (type) are the same in Nim. Need automatic collision detection and renaming
- [ ] C++ struct methods not generated — dearimgui structs with methods (e.g. `ImFontAtlas::GetTexDataAsRGBA32`) only emit fields, not methods. Only `class` goes through `toClass`; C++ structs with methods need the same treatment
- [ ] Better cint enum ergonomics — current `cint` alias + `const` works but loses type safety and IDE autocomplete
- [ ] so/dll/dylib
- [ ] write DSL for AST
- [ ] Support `{.compile.}` pragma for embedding C/C++ source alongside bindings
- [ ] Move multi-module rendering logic into slate (currently hardcoded in generator.nim)
- [ ] Per-module statement chain tracking for true multi-module output (currently all statements chain together, split by module.body)


## Testing
- [x] Test with libclang: self-hosting loop (generate api.nim → compile with it → regenerate → verify identical output)
- [x] Test with GLFW headers
- [ ] Test with stb_image and other stb headers (11/20 pass `nim check`)
  - [x] stb_image — generates, compiles, runs
  - [ ] `extern` macro values break 3 headers (stb_herringbone_wang_tile, stb_sprintf, stb_voxel_render)
  - [ ] Double underscores in type spellings not sanitized — `stbtt__buf` invalid in Nim (stb_truetype, stb_image_resize2)
  - [ ] Forward reference ordering — types used before defined (stb_ds, stb_rect_pack, stb_hexwave)
  - [ ] Type name used as const value — `stb_textedit` macro expands to type name
- [x] Test with OpenGL headers — gl.h/glext.h/glcorearb.h all pass `nim check` (20K lines total). Requires user callbacks for: type name collisions (`_t` suffix), khronos type mappings, C literal suffixes (`ull`→`'u64`), calling convention macro filtering
- [x] Test with raylib headers — 1279 lines, passes `nim check`, compiles and links against libraylib.a
  - [ ] Color macro constants (`CLITERAL(Color){...}`) need manual override — C compound literals have no Nim equivalent
  - [ ] Deprecated alias macros (`GetMouseRay = GetScreenToWorldRay`) reference symbols defined later — forward reference ordering
  - [ ] `va_list` type not mapped — requires user `typeMapper` to map to `pointer`
  - [ ] Visibility macros (`RLAPI`, `RMAPI`) expand to `extern` — need filtering
  - [ ] Float suffix `f` in macro values (`3.14f`) not stripped
- [ ] Test with Vulkan headers — 14434 lines generated from vulkan_core.h, triangle renders with manual fixes
  - [ ] Union typedef aliases emit as `incompleteStruct` instead of aliasing the union — `VkClearValue`, `VkClearColorValue` etc. need manual `= union_Vk*` fixup (12 types)
  - [ ] Deprecated macro aliases collide under Nim case-insensitivity — `VK_KHR_MAINTENANCE1` vs `VK_KHR_MAINTENANCE_1` (6 macros)
  - [ ] Enum value collisions — `VK_COLORSPACE_SRGB_NONLINEAR_KHR` vs `VK_COLOR_SPACE_SRGB_NONLINEAR_KHR` (2 values)
  - [ ] Video codec types (`StdVideoH264*`, `StdVideoH265*`) undeclared — from `vulkan_video_codec_*.h` not included (19 types, need stubs or include)
  - [x] Khronos type mappings, C literal suffixes, calling convention macros — handled by user callbacks
- [x] Test with SDL2/SDL3 headers — 15K lines generated from SDL.h, compiles and renders with manual fixups
  - [ ] Nim case-insensitive collisions between consts and types/procs (`SDL_QUIT`/`SDL_Quit`, `SDL_HAPTICCONSTANT`/`SDL_HapticConstant`, etc.)
  - [ ] C cast expressions in macro values (`((Uint32) -1)`)
  - [ ] Function-like macro calls in const values (`SDL_VERSIONNUM(...)`, `SDL_BUTTON(...)`)
  - [ ] Union typedef forward declaration issues (`SDL_Event`, `SDL_HapticEffect`)
  - [ ] Unnamed struct fields in unions (`SDL_RWops`, `SDL_GameControllerButtonBind`)
  - [ ] Compiler builtin macros (`__func__`, `__BYTE_ORDER`, `__GNUC__`)
  - [x] C operators in values, literal suffixes — handled by user callbacks
- [ ] Test with godot-cpp: 1055/1056 files generate without crashing, but each file re-emits all included symbols (~902K lines for 1056 files). Needs cross-file import tracking and symbol origin filtering to produce usable multi-file output. Also `CLASSDB_SINGLETON_FORWARD_METHODS` macro expands to ~6KB raw C++ in 952 files.
- [ ] Test with flecs — 9K lines generated from 40K line header
  - [ ] Forward references — 27 undeclared types used before defined. Needs two-pass generation
  - [ ] `ECS_CAST(type, value)` macro in const values — C cast expression, 21 occurrences
  - [ ] C struct initializer macros — `(ecs_strbuf_t){0}`, `ECS_HTTP_REPLY_INIT`, etc.
  - [ ] Function-like macro calls in values — `ecs_id(...)`, `ECS_SIZEOF(...)`, `ECS_ALIGN(...)`
  - [ ] Macro alias chains — `ECS_TAG_DECLARE = ECS_DECLARE`, `ecs_dbg = ecs_dbg_1`
  - [ ] `llu`/`ull` suffix variants on hex literals — `0xFFull`, `1llu`
  - [ ] `ptr void` from typedef-to-void pointer (`ecs_flagsn_t`)
- [ ] Test with qu3e (C++ physics) — 205 lines, 1 error: forward reference (`q3BodyType` enum used before defined). Macro constants use `r32()` cast wrapper and `FLT_MAX`
- [ ] Test with clay — 492 lines generated, only 5 errors. Blocked by double underscore in type references (`Clay__SizingType`). Macro-heavy API (designated initializers, comma operators) but most are function-like and correctly skipped
- [ ] Test with a large C++ library (Qt, LLVM, Boost) to stress-test template handling


## Documentation
- [ ] Write user-facing docs for callback APIs (renamer, symbolFilter, symbolOverride, typeMapper, pragmaOverride, etc.)
- [ ] Document the C vs C++ detection and `--cpp` flag behavior
- [ ] Document `LinkMode.header` vs `LinkMode.dynlib` tradeoffs
- [ ] Document `SingleFileParse` behavior and when to use it


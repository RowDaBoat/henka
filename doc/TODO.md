# Henka TODO
## Other v2 tasks
- [ ] Const static members skipped entirely — `static const int sMax` produces no binding (`toStaticField` bails at `cpp.nim:306` because the static-field path always emits a getter+setter pair and a const member can't have a setter). Should emit a getter-only accessor (`proc sMax(_: typedesc[Widget]): cint {.importcpp:"Widget::sMax".}`). See `tests/cpp/static_fields`.
- [ ] Namespace support — C++ namespaces are flattened into one top-level Nim module (`generator.nim:72` just descends into `CXCursor_Namespace` children, discarding the namespace as a Nim concept)
  - [ ] No Nim-level structure (no modules / prefixing / grouping) and no handling of cross-namespace name collisions — `a::Vec3` and `b::Vec3` both become `Vec3`. Only fixable via user `renamer`/`symbolFilter`. (Related: godot-cpp namespace qualifiers leaking, above.)
  - [ ] (Verify this is true before implementing) Enums lose namespace/class qualification in `importcpp` — `enumPragmas` (`pragmas.nim:182`) uses bare `cName` instead of `cursor.qualifiedName` like classes/funcs do. `math::Color` → `importcpp:"Color"`, `JPH::Color::Type` → `importcpp:"Type"`. Latent (Nim re-emits enums as its own `cint` type) but incorrect.
  - Namespace related tests
    - tests/cpp/big
    - tests/cpp/nested_qualified_types
- [ ] `using`/`typedef` aliases can emit a distinct opaque `{.incompleteStruct.} = object` instead of an `Alias = Underlying` alias — the result is a *new* type incompatible with the underlying one, so callers must comment out the pragma and `cast` to pass an underlying value where the alias is expected. The underlying types are emitted as full objects and most aliases render fine, so the alias *target* exists; only a subset of alias emissions is wrong. Two broken output shapes observed:
  - qualified `importcpp` (`Pkg::Alias`) — the forward-declared-class path, `classPragmas(isForward=true)` (`pragmas.nim:92`).
  - bare `importcpp`, no namespace qualifier — `toAlias`'s anonymous-struct branch (`statements.nim:29`; bare `name` at `:35`), taken when the underlying elaborated spelling contains a space.
  Which aliases degrade, and why, is not yet pinned down. Needs a minimal `tests/cpp` repro.
- [ ] write DSL for AST
- [ ] C++ reference semantics in bindings
  - [ ] `T&&` (rvalue ref) → `sink T` via `keyword: "sink"` on non-primitive types

- [ ] Pragma values as proper expressions — unquoted pragma values (like `sizeof(cint)`) are currently stored as `LiteralKind.generic` literals. They should be proper expression trees (identifier, call, etc.) once nonim codegen supports arbitrary expression generation.
- [ ] Macro expression parser — libclang only gives raw tokens for macros, no parse tree. Need a mini C expression parser to handle casts `(Type)val`, struct initializers `{0}`, function-like calls `FOO(a,b)`. Would fix most remaining macro-related failures (SDL, stb, flecs, raylib). Operators and literal suffixes now handled by `defaultValueMapper`.


## Enums
C enums are `cint` in C. The generated `cint` alias + `const` is correct for ABI. The missing piece is providing a Nim-ergonomic API on top of that `cint` representation.


### Modes (`EnumMode`)
- [ ] `Bitflag` — ordered Nim enum, fields without default values. Duplicates/combinations lost, converted to const, or converted to helper code depending on options.


### Options (`EnumOptions`)
- [ ] `NoHoles` — fill gaps with dummy values (bitflags cannot have holes)
- [ ] `Sort` — sort values before emitting (bitflags must be ordered)
- [ ] `Full` — emit helper code for the enum (not applicable to Const)
- [ ] Generate helper code for cint/distinct (`$`, comparison, conversion)
- [ ] Generate helper code for bitflags (enum sets)


### Edge cases
- [ ] Negative values: `SignedNeg = -1`
- [ ] Large values / sentinel: `Force32 = 0x7FFFFFFF`
- [ ] Holed enums: gaps in values
- [ ] Mixed implicit + explicit: `A, B = 5, C`


## Ergonomics (v2)
- [ ] Support `{.compile.}` pragma for embedding C/C++ source alongside bindings
- [ ] so/dll/dylib auto-resolution (current solution: `{.strdefine.}`)


## Testing
- [ ] Test with stb_image and other stb headers (20/20 pass `nim check` with user filters)
  - [ ] Macro alias chains — `stbds_arrlen` etc. are function-like macros that need the macro expression parser to convert properly
  - [ ] Type-as-value macros — `#define stbtt_vertex_type short` should emit a type alias, needs macro expression parser
  - [ ] `extern` as macro value — `#define STBHW_EXTERN extern` should be skipped or converted to a pragma, needs macro expression parser
- [ ] Test with raylib headers — 1238 lines, passes `nim check`, compiles and links against libraylib.a
  - [ ] Color macro constants (`CLITERAL(Color){...}`) need manual override — C compound literals have no Nim equivalent
- [ ] Test with SDL2/SDL3 headers — 2989 lines, 8 errors (all from one C cast expression on line 2)
  - [ ] C cast expressions in macro values (`((Sint8) 0x7F)`) — needs macro expression parser
  - [ ] Function-like macro calls in const values (`SDL_VERSIONNUM(...)`, `SDL_BUTTON(...)`) — not currently erroring (skipped or resolved by clang) but not properly converted
  - [ ] Compiler builtin macros (`__func__`, `__BYTE_ORDER`, `__GNUC__`) — not currently erroring but not properly handled
- [ ] Test with godot-cpp — 51273 lines from single mega-header, 6 errors:
  - [ ] `real_t` redefinition — `typedef float real_t` in C header collides with `using real_t = godot::real_t` in C++ namespace
  - [ ] C++ namespace qualifiers leaking — `godot::real_t` appears as raw text in output
  - [ ] `GDExtensionInitializationLevel` / `Callback` — cross-file types not resolved in single-file mode
  - [ ] Cross-file import tracking — multi-file mode re-emits all included symbols per file
- [ ] Test with flecs — 2945 lines, 130 errors
  - [ ] `let` symbol requires initialization — 130 errors: consts with macro values that couldn't be parsed emit as `let` with no value
  - [ ] `ECS_CAST(type, value)` macro in const values — C cast expression
  - [ ] C struct initializer macros — `(ecs_strbuf_t){0}`, `ECS_HTTP_REPLY_INIT`, etc.
  - [ ] Function-like macro calls in values — `ecs_id(...)`, `ECS_SIZEOF(...)`, `ECS_ALIGN(...)`
  - [ ] Macro alias chains — `ECS_TAG_DECLARE = ECS_DECLARE`, `ecs_dbg = ecs_dbg_1`
- [ ] Test with clay — 455 lines, passes `nim check`
  - [ ] Macro-heavy API — designated initializers, variadic macros, compound literals, function-like macros. All silently skipped. This IS clay's primary API surface. Needs macro expression parser. Zero filters needed, passes `nim check`, but bindings are incomplete.
- [ ] Test with a large C++ library (Qt, LLVM, Boost) to stress-test template handling


## Documentation
- [ ] Write user-facing docs for callback APIs (renamer, symbolFilter, symbolOverride, typeMapper, pragmaOverride, etc.)
- [ ] Document the C vs C++ detection and `--cpp` flag behavior
- [ ] Document `LinkMode.header` vs `LinkMode.dynlib` tradeoffs
- [ ] Document `SingleFileParse` behavior and when to use it

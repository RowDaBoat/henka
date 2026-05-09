# henka-js TODO

## Pipeline
- [x] TypeScript compiler API parses .ts and .js files
- [x] Produces astTF JSON matching the Zig spec format
- [x] Zig/slate codegen reads JSON and renders Nim output
- [x] Generated Nim compiles with `-b:js`

## Supported declarations
- [x] Function declarations → `proc` with `{.importjs.}`
- [x] Variable/const declarations → `const` with literal values
- [x] Interface declarations → `type = object` with fields
- [x] Type alias declarations → `type = alias` or inline object
- [x] Class declarations → `type = object` with fields + constructor + instance/static methods
- [x] Enum declarations → `type = cint`/`cstring` + const values (numeric and string enums)
- [x] Array types (`T[]`) → `seq[T]`
- [x] Callback/function types → procedure types with correct `proc(...)` rendering

## Type mappings
- [x] `number` → `cdouble`
- [x] `string` → `cstring`
- [x] `boolean` → `bool`
- [x] `void` → `void`
- [x] Type references (named types)
- [x] Object literal types
- [x] `any` → `JsObject` (auto-imports `std/jsffi` when `any` is used)
- [x] `number[]` / `Array<T>` → `seq[T]`
- [x] `string | number` (union types) → `JsObject`
- [x] `Promise<T>` → `Future[T]` (auto-imports `std/asyncjs`)
- [x] Optional types (`x?: T`, `T | undefined`) → `Option[T]` (auto-imports `std/options`)
- [x] Generic types (`Map<K,V>`, `Set<T>`, `Record<K,V>`) → `JsObject` fallback

## Class support
- [x] Classes emit as `distinct JsObject` — opaque handles, no nimCopy corruption
- [x] Fields → getter procs with `{.importjs:"#.fieldName".}`
- [x] Constructor → `proc newClassName(...): ClassName {.importjs: "new ClassName(@)".}`
- [x] Instance methods → `proc methodName(self: ClassName, ...) {.importjs: "#.methodName(@)".}`
- [x] Static methods → `proc methodName(...) {.importjs: "ClassName.methodName(@)".}`
- [x] Interface inheritance → `object of Parent`, `{.inheritable.}` only on types in inheritance chains

## Other features
- [x] Method signatures in interfaces
- [x] Default parameter values
- [x] Rest parameters (`...args`) → `varargs`
- [x] `declare` blocks (`.d.ts` files) — `declare function/class/interface/etc` work, TS parser handles them as regular declarations
- [x] Namespace declarations → `_` separated prefixes, `.` in importjs patterns
- [x] Nested/anonymous object types → `AnonymousN` synthetic types
- [x] Overloaded functions → native Nim overloads, implementation signatures filtered out, literal types mapped to base types

## Found in real-world testing (WebGPU, WebGL, lib.dom.d.ts)

### Fixed
- [x] Statement ordering — two-chain approach (types first, procs second), stitched at end like C/C++ henka
- [x] Classes as `distinct JsObject` — browser API classes are opaque references, not value-type data structs
- [x] Negative numeric literals — `TIMEOUT_IGNORED: -1` now handled via PrefixUnaryExpression in LiteralType

### Identifier issues
- [ ] `__` prefix identifiers — Nim rejects `__GPUDeviceEventMap` (leading underscore invalid in Nim)
- [ ] `__` prefix fields — `__brand: string` in WebGPU interfaces should be skipped (TS-internal branding)
- [ ] Quoted/string-literal field names — `"abort": Event` in interface maps produces `"abort"*` which is invalid Nim

### Type issues
- [ ] `undefined` as a field type — `z?: undefined` produces `Option[undefined]` instead of skipping the field
- [ ] `undefined` as a return type — WebGPU uses `): undefined` instead of `): void`. Should map to void or omit return type
- [ ] Unresolved TS utility types — `Required<T>`, `Omit<T,K>`, `Iterable<T>`, `Readonly<T>` fall through as raw text
- [ ] Generic type parameters in methods — `K extends keyof T` produces literal `K` type instead of `JsObject` or being skipped
- [ ] String union types — `type WebGLPowerPreference = "default" | "high-performance" | "low-power"` should map to `cstring`, not individual literal types
- [ ] `null` in union types — `T | null` should be `Option[T]` like `T | undefined`
- [ ] Overload deduplication — when literal types collapse to base types, identical proc signatures get emitted multiple times (e.g. `getExtension` in WebGL). Need signature-based dedup.
- [ ] Multi-extends interfaces — `WebGLRenderingContext extends WebGLRenderingContextBase, WebGLRenderingContextOverloads` only inherits from the first base. Methods from other bases are inaccessible. Need to flatten methods from all extended interfaces.
- [ ] Empty interfaces used as opaque handles — `interface WebGLShader {}` should emit as `JsObject` or `distinct JsObject`, not `object`. They're browser-native handles that can't be value-copied.

### Value issues
- [ ] Namespace `const` with no initializer — `export const gpu: GPU` in a namespace produces `const navigator_gpu* :GPU` with no value (invalid Nim)

### ES module / Next.js integration issues
- [ ] `{.emit.}` import placement — ES `import` statements land at the bottom of the generated JS (after Nim's runtime preamble) but must be at the top. Currently requires post-processing to move imports up.
- [ ] `{.importjs.}` procs are inlined, not defined as functions — can't be exported via `export { name }`. Need `{.exportc.}` wrapper functions or JS-level wrapper functions via `{.emit.}`.
- [ ] No automatic ES module generation — henka should be able to generate a `.nim` file that compiles to a valid ES module. Needs: emit import at top, exportc on public procs, emit export at bottom, post-process to fix import placement.

### astTF spec gaps
- [ ] Distinct type support — see `SPEC_GAP_DISTINCT_TYPES.md`. Currently hacked via primitive named `"distinct JsObject"`

## Design decisions
- No import resolution — process only files the user passes, like the C/C++ henka. External type references stay as opaque named types.
- Re-exports are irrelevant — user passes the actual `.d.ts` containing declarations, not barrel files

# Henka
`henka` generates Nim FFI bindings.
- Bindings for C/C++ headers are generated using `libclang`'s AST.
- Bindings for Javascript/Typescript code are generated using the typescript compiler's API (heysokam/js branch).
- Supports static and dynamic C/C++ library bindings.
- Can be used from the command line or as a library from your own bindings generator for more refined control of the output.
- Supports a wide variety of options and callbacks to customize the output to your needs, it allows renaming, filtering and overriding symbols, overriding values and pragmas, and naming anonymous fields among others.


## Installation
```
nimble install https://github.com/RowDaBoat/henka
```
Requires `libclang` available on your system.


## CLI Usage
```
henka [options] header.h [... more_headers.h]
```


### Options
| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show the help message |
| `--clangargs=...` | Forward arguments to clang |
| `--inpath=dir` | Input path to find headers (default: `.`) |
| `--outpath=dir` | Output path for generated bindings (default: the in-path) |
| `--cpp` | Compile using clang++ |
| `--std=c++17` | C++ standard to use |
| `--includeDir=path` | Specify a path to an includes directory |
| `-I=path` | Include path forwarded to the compiler |
| `-D=definition` | Define forwarded to the compiler |


### Examples
Generate bindings for a C header:
```sh
henka mylib.h
```

Generate bindings for C++ headers with include paths:
```sh
henka --cpp --std=c++17 -I=/usr/local/include api.hpp types.hpp
```

Output to a different directory:
```sh
henka --inpath=vendor/headers --outpath=src/bindings mylib.h
```


## Library Usage
Import `henka` and call `generate` to produce bindings programmatically:
```nim
import henka

let source = generate("mylib.h")
writeFile("mylib.nim", source)
```


### Multi-file generation
```nim
import std/os
import henka

let output = generate(
  inputFiles = @["types.h", "api.h"],
  clangArgs  = @["-I/usr/local/include"],
  rootPath   = "vendor/",
)

for module in output.modules:
  let nimPath = module.path.changeFileExt(".nim")
  writeFile(nimPath, module.definitions)
```


### C++ headers
```nim
let source = generate("engine.hpp", isCpp = true, clangArgs = @["-std=c++17"])
```


### Dynamic library bindings
By default henka generates `{.header.}` bindings. To generate `{.dynlib.}` bindings instead:

```nim
let source = generate("mylib.h",
  linkMode   = LinkMode.dynlib,
  dynlibName = "mylib_dll",
  dynlibPath = "libmylib.so",
)
```


### Callbacks
All callbacks have sensible defaults and are optional. Pass custom procs to control naming, filtering, type mapping, and more:

```nim
proc myRenamer(kind: LabelKind, name: string): string =
  case kind
  of StructType: name  # strip the default "struct_" prefix
  else: name

proc myFilter(kind: LabelKind, name: string): bool =
  not name.startsWith("internal_")

let source = generate("mylib.h",
  renamer      = myRenamer,
  symbolFilter = myFilter,
)
```

Available callbacks:

| Callback | Signature | Purpose |
|----------|-----------|---------|
| `renamer` | `(LabelKind, string): string` | Rename symbols in output |
| `sanitizer` | `(string): string` | Sanitize identifiers (dedup underscores, prefix private names) |
| `symbolFilter` | `(LabelKind, string): bool` | Return `false` to skip a symbol |
| `symbolOverride` | `(LabelKind, string): Option[string]` | Replace a symbol with custom source text |
| `typeMapper` | `(string): Option[string]` | Map C type names to Nim types |
| `valueMapper` | `(string): string` | Transform macro/const values |
| `pragmaOverride` | `(LabelKind, string, seq[...]): seq[...]` | Override pragmas on declarations |
| `enumModeSelect` | `(string, LabelKind, EnumConfig): EnumConfig` | Per-enum mode/options selection |
| `unnamedFieldNamer` | `(string, int): string` | Name unnamed struct/union fields |
| `constructorName` | `(string): string` | Pattern for C++ constructor bindings |
| `destructorName` | `(string): string` | Pattern for C++ destructor bindings |


### Enum modes
Control how C/C++ enums are represented in Nim:

```nim
let source = generate("mylib.h",
  enumMode    = EnumMode.Enum,       # Nim enum (default)
  enumOptions = {EnumOption.Pure},   # {.pure.} pragma (default)
)
```

| Mode | Description |
|------|-------------|
| `EnumMode.Enum` | Proper Nim `enum` type with fields |
| `EnumMode.Cint` | Type aliased to `cint`, values as constants |
| `EnumMode.Const` | No type emitted, values become comptime int constants |

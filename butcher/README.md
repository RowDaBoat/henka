# henka - a C to Nim Binding Generator

**`henka`** generates Nim `{.importc.}` bindings from C header files. It uses Clang to parse headers into a JSON AST, then emits Nim definitions mapping C types, variables, and functions to Nim, supporting `union`, `struct`, `enum`, `typedef`, functions, constants, and variables.

**Requirements**: `clang` and `nim` compilers. Nothing else.

**Henka** means variation in japanese.

## Usage
```sh
henka header.h > header.nim
```

Given a header like this:

```c
typedef struct Circle { float radius; } Circle;
typedef struct Rectangle { float width; float height; } Rectangle;

typedef enum ShapeKind {
    ShapeKindCircle, ShapeKindRectangle,
} ShapeKind;

typedef float (*ShapeCalculatorFn)(Shape shape);

float shapeArea(Shape shape);
float shapePerimeter(Shape shape);
```

`henka` produces:

```nim
type Circle* {.importc, bycopy, header: "shapes.h".} = object
  radius*: cfloat

type Rectangle* {.importc, bycopy, header: "shapes.h".} = object
  width*: cfloat
  height*: cfloat

type ShapeKind* {.size: sizeof(cint).} = enum
  ShapeKindCircle,
  ShapeKindRectangle

type ShapeCalculatorFn* = proc(a0: Shape): cfloat {.cdecl.}

proc shapeArea*(shape: Shape): cfloat {.importc, cdecl, header: "shapes.h".}
proc shapePerimeter*(shape: Shape): cfloat {.importc, cdecl, header: "shapes.h".}
```


### Options
```
Usage: henka [options] <header.h> [header.h ...]

  -h, --help                  Show this help message
  --clangargs:<args>          Forward arguments to clang
  --astout:<path>             Output the generated JSON AST to this path
  --nimout:<path>             Output the generated Nim bindings to this path (default: stdout)
  --jsonast:<path>            Use an existing JSON AST instead of invoking clang
```

## Renaming
Import `henka` as a library to customise how declaration names are rewritten. Supply a `Renamer` — a `proc(kind: LabelKind, label: string): RenameResult` — to `generateBindings`.

The following example:
- strips the `shape` prefix from functions
- strips the `ShapeKind` prefix from enum values
- adds a `pure` pragma to enum types

```nim
import henka, strutils, strformat

proc renamer(kind: LabelKind, label: string): RenameResult =
  case kind
  of EnumType:
    (name: label, pragmas: @["pure"])
  of EnumValue:
    (name: label.removePrefix("ShapeKind"), pragmas: @[])
  of Proc:
    (name: label.removePrefix("shape").toLowerAscii, pragmas: @[])
  else:
    (name: label, pragmas: @[])

let jsonAst = generateAst(@["shapes.h"])
let bindings = generateBindings(jsonAst, renamer)
writeFile("shapes.nim", bindings)
```

The default output:

```nim
type ShapeKind* {.size: sizeof(cint).} = enum
  ShapeKindCircle,
  ShapeKindRectangle,
  ShapeKindTriangle,
  ShapeKindLine

proc shapeArea*(shape: Shape): cfloat {.importc, cdecl, header: "shapes.h".}
proc shapePerimeter*(shape: Shape): cfloat {.importc, cdecl, header: "shapes.h".}
```

Becomes:

```nim
type ShapeKind* {.size: sizeof(cint), pure.} = enum
  Circle,
  Rectangle,
  Triangle,
  Line

proc area*(shape: Shape): cfloat {.importc, cdecl, header: "shapes.h".}
proc perimeter*(shape: Shape): cfloat {.importc, cdecl, header: "shapes.h".}
```

`LabelKind` lets the renamer target specific declaration categories:

| Kind                      | Applies to                   |
|---------------------------|------------------------------|
| `StructType`, `UnionType` | struct / union type names    |
| `EnumType`, `EnumValue`   | enum type and value names    |
| `Typedef`                 | typedef aliases              |
| `Proc`, `Parameter`       | function and parameter names |
| `Variable`, `Constant`    | variable and constant names  |
| `Field`                   | struct / union field names   |


## Extending and fixing `henka`

`henka` tries to cover common C constructs but not every edge case. It is intentionally written to be simple and readable so that an AI can understand, fix, and extend it with minimal friction.

If a header file is not parsed correctly, a good approach is to give an AI agent the header and the error or wrong output, then ask it to fix `henka` to support it, then submit a PR once it works.

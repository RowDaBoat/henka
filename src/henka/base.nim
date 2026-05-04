# @deps std
from std/options import Option, none, some, isSome, isNone, get
from std/sets import HashSet, initHashSet, incl, contains
from std/tables import Table, initTable, `[]=`, `[]`, hasKey, contains
# @deps slate
import slate/ast as astTF
# @deps henka
import ./clang

export Option, none, some, isSome, isNone, get
export HashSet, initHashSet, incl, sets.contains
export Table, initTable, `[]=`, `[]`, hasKey, tables.contains

type EnumOption* {.pure.}= enum
  Pure      ## {.pure.} pragma will be added to the resulting type
  Distinct  ## The type is declared as `distinct`  (not applicable to Mode.Const)
  NoHoles   ## Fill the gaps/holes with dummy values  (bitflags cannot have holes)  https://nim-lang.org/docs/manual.html#types-enumeration-types
  Sort      ## Sort values before emitting its code  (bitflags must be ordered)    https://nim-lang.org/docs/manual.html#types-enumeration-types
  Full      ## Will emits helper code for the enum  (not applicable to Mode.Const)
  # TODO:
  # - Generate helper code for cint/distinct
  # - Generate helper code for bitflags (enum sets)   https://nim-lang.org/docs/manual.html#set-type-bit-fields
  # - Fill in value holes
  # - Order enums by value
type EnumOptions * = set[EnumOption]
template Default *(_:typedesc[EnumOptions]) :EnumOptions= {EnumOption.Pure}
  ## Henka decides what to use  (aka. sane defaults)

type EnumMode* {.pure.}= enum
  Default  ## Henka decides what to use  (aka. sane defaults)
  Const    ## TODO: All fields become separate implicit comptime ints, and a type is not emitted
  Cint     ## The type is aliased to `cint`, and its values become separate constants of that type
  Enum     ## Type is converted to nim enum, and its values become its fields
  Bitflag  ## TODO: Type is converted to ordered nim enum, fields generated without default values. Duplicates/combinations are either lost, converted to const, or converted to helper code, depending on EnumOptions.

type EnumConfig* = object
  mode*    : EnumMode    = EnumMode.Default
  options* : EnumOptions = EnumOptions.Default

type LinkMode* {.pure.}= enum
  header
  dynlib

type LabelKind* = enum
  Proc,       Parameter, Variable, Constant
  EnumType,   EnumClass, EnumValue
  StructType, UnionType, Field
  Typedef

type EnumModeSelect*    = proc(name: system.string, kind: LabelKind, config: EnumConfig): EnumConfig
type Renamer*           = proc(kind: LabelKind, name: system.string): system.string
type SymbolFilter*      = proc(kind: LabelKind, name: system.string): bool
type SymbolOverride*    = proc(kind: LabelKind, name: system.string): Option[system.string]
type NamePattern*       = proc(className: system.string): system.string
type UnnamedFieldNamer* = proc(parentName: system.string, index: int): system.string
type TypeMapper*        = proc(name: system.string): Option[system.string]
type PragmaOverride*    = proc(kind: LabelKind, name: system.string, defaults: seq[(system.string, system.string)]): seq[(system.string, system.string)]
type ValueMapper*       = proc(value: system.string): system.string
type Sanitizer*         = proc(name: system.string): system.string

type Converter* = object
  ast*               : astTF.Ast
  headerFile*        : string
  rootDir*           : system.string
  module*            : astTF.Id
  tu*                : CXTranslationUnit
  seenStructs*       : Table[system.string, (astTF.Id, astTF.Id)]
  seenEnums*         : HashSet[system.string]
  seenSymbols*       : HashSet[system.string]
  seenTypedefs*      : HashSet[system.string]
  renamer*           : Renamer
  lastStatement*     : Option[astTF.Id]
  firstAliasStmt*    : Option[astTF.Id]
  lastAliasStmt*     : Option[astTF.Id]
  firstTypeStmt*     : Option[astTF.Id]
  lastTypeStmt*      : Option[astTF.Id]
  firstOtherStmt*    : Option[astTF.Id]
  lastOtherStmt*     : Option[astTF.Id]
  isCpp*             : bool
  linkMode*          : LinkMode
  dynlibName*        : system.string
  dynlibPath*        : system.string
  constructorName*   : NamePattern
  destructorName*    : NamePattern
  symbolFilter*      : SymbolFilter
  symbolOverride*    : SymbolOverride
  unnamedFieldNamer* : UnnamedFieldNamer
  typeMapper*        : TypeMapper
  sanitizer*         : Sanitizer
  pragmaOverride*    : PragmaOverride
  valueMapper*       : ValueMapper
  enumModeSelect*    : EnumModeSelect
  enumMode*          : EnumMode    = EnumMode.Default
  enumOptions*       : EnumOptions = EnumOptions.Default

type ChildCtx* = object
  conv*           :ptr Converter
  ids*            :seq[astTF.Id]
  name*           :system.string
  pendingTypeId*  :Option[astTF.Id]
  isDistinct*     :bool


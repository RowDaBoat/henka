# @deps std
from std/options import Option, none, some, isSome
from std/sets import HashSet, initHashSet, incl, contains
# @deps slate
import slate/ast as astTF
# @deps henka
import ./clang

export Option, none, some, isSome
export HashSet, initHashSet, incl, contains

type LinkMode* {.pure.}= enum
  header
  dynlib

type LabelKind* = enum
  Proc,       Parameter, Variable, Constant
  EnumType,   EnumClass, EnumValue
  StructType, UnionType, Field
  Typedef

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
  seenStructs*       : HashSet[system.string]
  seenEnums*         : HashSet[system.string]
  seenSymbols*       : HashSet[system.string]
  renamer*           : Renamer
  lastStatement*     : Option[astTF.Id]
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

type ChildCtx* = object
  conv*  :ptr Converter
  ids*   :seq[astTF.Id]
  name*  :system.string


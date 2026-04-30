# @deps std
from std/strutils import startsWith
# @deps henka
import ./common

proc defaultConstructorName   *(className :system.string) :system.string= className & "_create"
proc defaultDestructorName    *(className :system.string) :system.string= "destroy"
proc defaultSymbolFilter      *(kind :LabelKind; name :system.string) :bool= true
proc defaultSymbolOverride    *(kind :LabelKind; name :system.string) :Option[system.string]= none(system.string)
proc defaultUnnamedFieldNamer *(parentName :system.string; index :int) :system.string= "unnamed" & $index

proc defaultRenamer *(kind :LabelKind; name :system.string) :system.string=
  var cleaned = name
  if cleaned.startsWith("_"): cleaned = "priv" & cleaned
  result = case kind
    of StructType : "struct_" & cleaned
    of UnionType  : "union_" & cleaned
    of EnumType   : "enum_" & cleaned
    of EnumClass  : cleaned
    else          : cleaned

const standardTypeMappings *:seq[(system.string, system.string)]= @[
  ("size_t",    "csize_t"),
  ("ssize_t",   "int"),
  ("ptrdiff_t", "int"),
  ("intptr_t",  "int"),
  ("uintptr_t", "uint"),
  ("int8_t",    "int8"),
  ("int16_t",   "int16"),
  ("int32_t",   "int32"),
  ("int64_t",   "int64"),
  ("uint8_t",   "uint8"),
  ("uint16_t",  "uint16"),
  ("uint32_t",  "uint32"),
  ("uint64_t",  "uint64"),
]

proc defaultTypeMapper*(name :system.string) :Option[system.string]=
  for mapping in standardTypeMappings:
    if name == mapping[0]: return some(mapping[1])
  result = none(system.string)


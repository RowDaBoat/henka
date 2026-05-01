# @deps std
from std/strutils import startsWith
# @deps henka
import ./common

proc defaultConstructorName*(className: system.string): system.string =
  className & "_create"

proc defaultDestructorName*(className: system.string): system.string =
  "destroy"

proc defaultSymbolFilter*(kind: LabelKind, name: system.string): bool =
  true

proc defaultSymbolOverride*(kind: LabelKind, name: system.string): Option[system.string] =
  none(system.string)

proc defaultUnnamedFieldNamer*(parentName: system.string, index: int): system.string =
  "unnamed" & $index

proc defaultRenamer*(kind :LabelKind, name: system.string): system.string=
  var cleaned = name
  if cleaned.startsWith("_"):
    cleaned = "priv" & cleaned

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


proc defaultTypeMapper*(name: system.string): Option[system.string]=
  for mapping in standardTypeMappings:
    if name == mapping[0]:
      return some(mapping[1])

  result = none(system.string)


const standardValueMappings *:seq[(system.string, system.string)]= @[
  ("UINT8_MAX",  "high(uint8)"),
  ("UINT16_MAX", "high(uint16)"),
  ("UINT32_MAX", "high(uint32)"),
  ("UINT64_MAX", "high(uint64)"),
  ("INT8_MAX",   "high(int8)"),
  ("INT16_MAX",  "high(int16)"),
  ("INT32_MAX",  "high(int32)"),
  ("INT64_MAX",  "high(int64)"),
  ("INT8_MIN",   "low(int8)"),
  ("INT16_MIN",  "low(int16)"),
  ("INT32_MIN",  "low(int32)"),
  ("INT64_MIN",  "low(int64)"),
  ("SIZE_MAX",   "high(csize_t)"),
  ("NAN",        "NaN"),
  ("INFINITY",   "Inf"),
]

proc defaultValueMapper*(value: system.string): system.string=
  result = value

  for mapping in standardValueMappings:
    if result == "( " & mapping[0] & " )":
      return mapping[1]

    if result == mapping[0]:
      return mapping[1]

proc defaultPragmaOverride*(
  kind: LabelKind, 
  name: system.string, 
  defaults: seq[(system.string, system.string)]
): seq[(system.string, system.string)] =
  defaults

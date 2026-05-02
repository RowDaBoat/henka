# @deps std
from std/strutils import startsWith, endsWith, replace, toUpperAscii, contains
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

proc dedupUnderscores *(label :system.string) :system.string=
  var wasUnderscore = false
  for character in label:
    let isUnderscore = character == '_'
    if not (isUnderscore and wasUnderscore):
      result.add character
    wasUnderscore = isUnderscore

proc defaultSanitizer *(name :system.string) :system.string=
  result =
    if   name.startsWith("__") : "internal" & name
    elif name.startsWith("_")  : "priv" & name
    else                       : name
  result = result.dedupUnderscores
  while result.endsWith("_"):
    result = result[0..^2]

proc defaultRenamer*(kind :LabelKind, name: system.string): system.string=
  result = case kind
    of StructType : "struct_" & name
    of UnionType  : "union_" & name
    of EnumType   : "enum_" & name
    of EnumClass  : name
    else          : name


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
  ("va_list",   "pointer"),
  ("wchar_t",   "cuint"),
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

proc stripCSuffix*(value: system.string): system.string =
  result = ""
  var idx = 0
  while idx < value.len:
    if value[idx] in {'0'..'9'} or (value[idx] == '0' and idx + 1 < value.len and value[idx + 1] in {'x', 'X'}):
      var numEnd = idx
      while numEnd < value.len and value[numEnd] in {'0'..'9', 'a'..'f', 'A'..'F', 'x', 'X', '.'}:
        numEnd += 1
      let numStr = value[idx..<numEnd]
      var suffix = ""
      while numEnd < value.len and value[numEnd] in {'L', 'l', 'U', 'u', 'F', 'f'}:
        suffix.add value[numEnd]
        numEnd += 1
      result.add numStr
      let upper = suffix.toUpperAscii
      if "ULL" in upper:       result.add "'u64"
      elif "LL" in upper:      result.add "'i64"
      elif "UL" in upper:      result.add "'u64"
      elif "U" in upper:       result.add "'u32"
      idx = numEnd
    else:
      result.add value[idx]
      idx += 1

proc defaultValueMapper*(value: system.string): system.string=
  result = value

  for mapping in standardValueMappings:
    if result == "( " & mapping[0] & " )":
      return mapping[1]

    if result == mapping[0]:
      return mapping[1]

  result = result.stripCSuffix
  result = result.replace("<<", "shl").replace(">>", "shr")
  result = result.replace("|", "or").replace("&", "and").replace("~", "not")

proc defaultPragmaOverride*(
  kind: LabelKind,
  name: system.string,
  defaults: seq[(system.string, system.string)]
): seq[(system.string, system.string)] =
  defaults

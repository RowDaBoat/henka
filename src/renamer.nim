type LabelKind* = enum
  Variable, Constant
  Proc, Argument
  EnumType
  StructType, UnionType, Field


type Renamer* = proc(kind: LabelKind, label: string): string


proc dedupUnderscores*(label: string): string =
  var wasUnderscore = false

  for c in label:
    let isUnderscore = c == '_'

    if not (isUnderscore and wasUnderscore):
      result &= c
    wasUnderscore = isUnderscore


proc defaultRenamer*(kind: LabelKind, label: string): string =
  let dedupedLabel = label.dedupUnderscores
  case kind
  of EnumType:   "enum_" & dedupedLabel
  of StructType: "struct_" & dedupedLabel
  of UnionType:  "union_" & dedupedLabel  
  else: dedupedLabel

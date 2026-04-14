type LabelKind* = enum
  Variable, Constant
  Proc, Parameter
  EnumType, EnumValue
  StructType, UnionType, Field
  Typedef


type RenameResult* = tuple[name: string, pragmas: seq[string]]

type Renamer* = proc(kind: LabelKind, label: string): RenameResult


proc dedupUnderscores*(label: string): string =
  var wasUnderscore = false

  for c in label:
    let isUnderscore = c == '_'

    if not (isUnderscore and wasUnderscore):
      result &= c
    wasUnderscore = isUnderscore


proc defaultRenamer*(kind: LabelKind, label: string): RenameResult =
  let dedupedLabel = label.dedupUnderscores
  let name = case kind
    of EnumType:   "enum_" & dedupedLabel
    of StructType: "struct_" & dedupedLabel
    of UnionType:  "union_" & dedupedLabel
    else: dedupedLabel
  (name: name, pragmas: @[])

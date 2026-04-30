
proc dedupUnderscores*(label: string): string =
  var wasUnderscore = false

  for c in label:
    let isUnderscore = c == '_'

    if not (isUnderscore and wasUnderscore):
      result &= c
    wasUnderscore = isUnderscore


proc sanitizer*(renamer: Renamer): Renamer =
  proc (kind: LabelKind, label: string): RenameResult =
    let dedupedLabel = label.dedupUnderscores
    let name = case kind
      of EnumType:   "enum_" & dedupedLabel
      of StructType: "struct_" & dedupedLabel
      of UnionType:  "union_" & dedupedLabel
      else: dedupedLabel.escapeKeyword
    renamer(kind, name)


import std/strformat


type LabelKind* = enum
  Variable, Constant
  Proc, Parameter
  EnumType, EnumValue
  StructType, UnionType, Field
  Typedef


type RenameResult* = tuple[name: string, pragmas: seq[string]]

type Renamer* = proc(kind: LabelKind, label: string): RenameResult


const nimKeywords = [
  "addr", "and", "as", "asm", "bind", "block", "break", "case", "cast",
  "concept", "const", "continue", "converter", "defer", "discard", "distinct",
  "div", "do", "elif", "else", "end", "enum", "except", "export", "finally",
  "for", "from", "func", "if", "import", "in", "include", "interface",
  "is", "isnot", "iterator", "let", "macro", "method", "mixin", "mod",
  "nil", "not", "notin", "object", "of", "or", "out", "proc", "ptr",
  "raise", "ref", "return", "shl", "shr", "static", "template", "try",
  "tuple", "type", "using", "var", "when", "while", "xor", "yield"
]


proc escapeKeyword*(label: string): string =
  if label in nimKeywords: &"`{label}`"
  else: label


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
    else: dedupedLabel.escapeKeyword
  (name: name, pragmas: @[])

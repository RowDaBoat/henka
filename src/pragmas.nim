import std/strformat


proc importcPragma*(name, renamed: string): string =
  if name != renamed: &"importc: \"{name}\"" else: "importc"

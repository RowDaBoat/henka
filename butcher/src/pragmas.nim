import std/[strformat, strutils]


proc pragmas*(pragmas: seq[string]): string =
  if pragmas.len == 0:
    return ""

  " {." & pragmas.join(", ") & ".}"


proc importc*(name, renamed: string): string =
  if name != renamed: &"importc: \"{name}\"" else: "importc"

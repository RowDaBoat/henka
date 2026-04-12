proc error*(message: string) =
  stderr.writeLine message
  quit(1)

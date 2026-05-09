type
  enum_BitFlag* {.pure, size:sizeof(cint), importc:"enum BitFlag", header:"tests/c/enums_bitflags/header.h".} = enum
    FlagA = 1,
    FlagB = 2,
    FlagC = 4,
    FlagD = 8,
    FlagAll = 15
  BitFlag* = enum_BitFlag

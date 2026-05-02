type
  enum_Color* = cint
  Color* = enum_Color
  enum_Flags* = cint
  Flags* = enum_Flags
const
  Red* :enum_Color= 0
  Green* :enum_Color= 1
  Blue* :enum_Color= 2
  ColourRed* :enum_Color= 0
  ColourGreen* :enum_Color= 1
  ColourBlue* :enum_Color= 2
  None* :enum_Flags= 0
  Default* :enum_Flags= 0
  Read* :enum_Flags= 1
  Write* :enum_Flags= 2
  Execute* :enum_Flags= 4
  All* :enum_Flags= 7

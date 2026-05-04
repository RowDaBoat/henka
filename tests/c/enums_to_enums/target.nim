import bindings

when not (None is Flags):
  {.error: "Flags enum values must be of type Flags".}
when not (Read is Flags):
  {.error: "Flags enum values must be of type Flags".}
when not (Write is Flags):
  {.error: "Flags enum values must be of type Flags".}
when not (Execute is Flags):
  {.error: "Flags enum values must be of type Flags".}
when not compiles({ Read, Write, Execute }):
  {.error: "Flags enum values must be usable in a set".}

when Red != ColourRed:
  {.error: "Color Red value must be aliased as ColourRed".}
when Green != ColourGreen:
  {.error: "Color Green value must be aliased as ColourGreen".}
when Blue != ColourBlue:
  {.error: "Color Blue value must be aliased as ColourBlue".}

when Flags.None.int != 0:
  {.error: "Color enums values must be properly set".}
when Flags.Read.int != 1:
  {.error: "Color enums values must be properly set".}
when Flags.Write.int != 2:
  {.error: "Color enums values must be properly set".}
when Flags.Execute.int != 4:
  {.error: "Color enums values must be properly set".}
when Flags.All.int != 7:
  {.error: "Color enums values must be properly set".}

import bindings

# =========================================
# Basic sequential enum: implicit 0,1,2,3
# =========================================
when North.int != 0: {.error: "North must be 0".}
when East.int != 1: {.error: "East must be 1".}
when South.int != 2: {.error: "South must be 2".}
when West.int != 3: {.error: "West must be 3".}

# Ordering: north < east < south < west
when not (North < East): {.error: "North must be < East".}
when not (East < South): {.error: "East must be < South".}
when not (South < West): {.error: "South must be < West".}

# Equality
when North == East: {.error: "North must != East".}

# =========================================
# Explicit sequential: same as implicit but explicit
# =========================================
when ExplicitA.int != 0: {.error: "ExplicitA must be 0".}
when ExplicitB.int != 1: {.error: "ExplicitB must be 1".}
when ExplicitC.int != 2: {.error: "ExplicitC must be 2".}

# =========================================
# Holed enum: values with gaps
# =========================================
when HoledA.int != 2: {.error: "HoledA must be 2".}
when HoledB.int != 4: {.error: "HoledB must be 4".}
when HoledC.int != 89: {.error: "HoledC must be 89".}

# Holed enums are NOT ordinal in Nim:
# inc/dec/succ/pred should NOT work
# Arrays indexed by holed enum should NOT work
when compiles(succ(HoledA)): {.error: "succ must not work on holed enum".}
when compiles(pred(HoledC)): {.error: "pred must not work on holed enum".}

# =========================================
# Duplicate values (aliases)
# =========================================
when DupeFirst.int != 0: {.error: "DupeFirst must be 0".}
when DupeSecond.int != 1: {.error: "DupeSecond must be 1".}
when DupeAlias0.int != 0: {.error: "DupeAlias0 must be 0".}
when DupeAlias1.int != 1: {.error: "DupeAlias1 must be 1".}
when DupeFirst != DupeAlias0: {.error: "DupeFirst must == DupeAlias0".}

# =========================================
# Negative values
# =========================================
when SignedNeg.int != -1: {.error: "SignedNeg must be -1".}
when SignedZero.int != 0: {.error: "SignedZero must be 0".}
when SignedPos.int != 1: {.error: "SignedPos must be 1".}
when not (SignedNeg < SignedZero): {.error: "SignedNeg must be < SignedZero".}

# =========================================
# Bit flags
# =========================================
when FlagA.int != 1: {.error: "FlagA must be 1".}
when FlagB.int != 2: {.error: "FlagB must be 2".}
when FlagC.int != 4: {.error: "FlagC must be 4".}
when FlagD.int != 8: {.error: "FlagD must be 8".}
when FlagAll.int != 15: {.error: "FlagAll must be 15".}

# Bit flags should be usable in sets:
when not compiles({FlagA, FlagB}): {.error: "BitFlag must be usable in sets".}
when compiles({FlagA, FlagB}):
  assert cast[int]({FlagA, FlagB}) == 3

# =========================================
# typedef enum
# =========================================
when OptionNone.int != 0: {.error: "OptionNone must be 0".}
when OptionSome.int != 1: {.error: "OptionSome must be 1".}
when OptionAll.int != 2: {.error: "OptionAll must be 2".}

# =========================================
# Anonymous enum (just constants)
# =========================================
when ANON_CONST_A != 42: {.error: "ANON_CONST_A must be 42".}
when ANON_CONST_B != 100: {.error: "ANON_CONST_B must be 100".}

# =========================================
# Large values / sentinel
# =========================================
when SentinelA.int != 0: {.error: "SentinelA must be 0".}
when SentinelB.int != 1: {.error: "SentinelB must be 1".}
when SentinelForce32.int != 0x7FFFFFFF: {.error: "SentinelForce32 must be 0x7FFFFFFF".}

# =========================================
# Enum in function signatures (type compatibility)
# =========================================
when not compiles(get_status()): {.error: "get_status must be callable".}
when not compiles(set_status(StatusOk)): {.error: "set_status must accept Status values".}

# =========================================
# Enum in struct fields
# =========================================
var h: HasEnum
h.value = 1
when not compiles(h.dir): {.error: "HasEnum must have dir field".}
when not compiles(h.status): {.error: "HasEnum must have status field".}

# =========================================
# Single value enum
# =========================================
when OnlyOne.int != 0: {.error: "OnlyOne must be 0".}

# =========================================
# Offset enum (starts from non-zero)
# =========================================
when OffsetA.int != 10: {.error: "OffsetA must be 10".}
when OffsetB.int != 11: {.error: "OffsetB must be 11".}
when OffsetC.int != 12: {.error: "OffsetC must be 12".}

# =========================================
# Mixed implicit + explicit
# =========================================
when MixedA.int != 0: {.error: "MixedA must be 0 (implicit)".}
when MixedB.int != 5: {.error: "MixedB must be 5 (explicit)".}
when MixedC.int != 6: {.error: "MixedC must be 6 (implicit after 5)".}
when MixedD.int != 20: {.error: "MixedD must be 20 (explicit)".}
when MixedE.int != 21: {.error: "MixedE must be 21 (implicit after 20)".}

# =========================================
# Type qualification: EnumType.value
# =========================================
when not compiles(Direction.North): {.error: "Direction.North must be valid".}
when Direction.North != North: {.error: "Direction.North must equal North".}

# =========================================
# Stringify: $enumValue
# =========================================
when not compiles($North): {.error: "$North must compile".}

echo "All enum tests passed"

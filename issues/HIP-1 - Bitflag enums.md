# HIP-1 - Bitflag enums
**Status:** Open


## Bug
Bitflag enums (power-of-two values) are generated as plain enums. The test `enums_bitflags` expects them to support Nim `set` operations, but the generated binding does not produce a set-compatible representation.

The generated output matches `header.nim` (a plain enum), while `target.nim` asserts set semantics like `{FlagA, FlagB} is set[enum_BitFlag]`.


## Fix
-


## Notes
- Tests: implemented (`tests/c/enums_bitflags/`)
- Feature: not implemented

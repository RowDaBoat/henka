# HIP-2 - Full macro support
**Status:** Open


## Problem
Only simple `#define` macros (literal integers and strings) are translated. Expression macros (`#define COMBINED (FLAG_A | FLAG_B)`) and function-like macros (`#define FUNC_LIKE(x) ((x) + 1)`) are not fully supported.

The current test (`tests/c/macros/`) covers simple cases but does not assert on expression or function-like macros.


## Solution
-


## Notes
- Tests: not implemented
- Feature: not implemented
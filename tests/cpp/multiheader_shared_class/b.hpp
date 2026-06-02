#pragma once
#include "a.hpp"

// Parsing this header (module 1) re-encounters Counter through the include.
// Before the fix this re-emitted Counter's methods (redefinition) and rebuilt
// its type node under module 1's source, corrupting module 0's output.
int reset(int value);

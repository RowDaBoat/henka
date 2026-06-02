#pragma once
#include "a.hpp"

// Full definition (module 1) upgrades the forward declaration from module 0.
// The upgraded node lives in module 0's body, so its source offsets must be
// built against module 0 — otherwise module 0 renders garbage.
class Engine {
public:
    int rpm();
};

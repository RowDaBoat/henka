# HIP-3 - Constants from expressions
**Status:** Open


## Bug
Constants defined with expressions are not being properly rendered in the generated Nim output. The expression is either dropped or rendered incorrectly.

e.g. this declaration from `wgvk.h`:
```c
static const WGPUShaderStage WGPUShaderStage_Compute = (((WGPUFlags)1) << WGPUShaderStageEnum_Compute);
```
results in:
```nim
const WGPUShaderStage_Compute*: WGPUShaderStage = 1
```

## Fix
-


## Notes
- Tests: not implemented
- Feature: not implemented

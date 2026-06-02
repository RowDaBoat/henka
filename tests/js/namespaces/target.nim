import bindings

discard Math_add(1.0, 2.0)
discard Math_sub(3.0, 1.0)
discard Math_PI

var vec: Math_Vec2
vec.x = 1.0
vec.y = 2.0
discard Math_magnitude(vec)

var opts: App_Config_Options
opts.debug = true
opts.verbose = false
discard App_Config_load("/config")
App_start()

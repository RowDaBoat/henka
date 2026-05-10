import bindings

var config: Config
config.mode = ColorMode_light
config.size = Size_small
config.label = "test"

setMode(ColorMode_dark)
setSize(Size_medium)
configure(config)

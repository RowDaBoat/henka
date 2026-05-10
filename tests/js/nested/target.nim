import bindings

var config: Anonymous0
config.width = 800.0
config.height = 600.0
config.title = "test"
createWindow(config)

var shape: Anonymous1
shape.x = 10.0
shape.y = 20.0

var color: Anonymous2
color.r = 1.0
color.g = 0.0
color.b = 0.0
draw(shape, color)

var app: App
discard app.window
discard app.settings

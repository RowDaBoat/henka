import bindings

var device: internal_Device
device.internal_brand = "x"
device.priv_field = "y"
device.label = "z"

discard internal_create()
priv_helper(1.0)

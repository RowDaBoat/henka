import bindings

proc onLost(device: ptr Device) {.cdecl.} = discard

var info: CallbackInfo
info.callback = onLost

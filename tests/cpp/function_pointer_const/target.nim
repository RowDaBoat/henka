import bindings

proc callback(param: ptr ConstStruct) {.cdecl.} = discard

var info: CallbackInfo
info.callback = toCallback(callback)

var info2 = CallbackInfo(callback: toCallback(callback))

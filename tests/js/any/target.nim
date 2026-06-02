import bindings

var store: DynamicStore
discard store.data
discard parse("test")
discard stringify(store.data)
discard clone(store.data, true)
discard store.get("key")
store.set("key", store.data)

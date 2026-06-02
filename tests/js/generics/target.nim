import bindings

var cache: Cache
discard cache.entries
discard cache.keys
discard getMap()
discard getSet()
discard toRecord(cache.entries)
discard cache.get("key")
cache.set("key", "value")

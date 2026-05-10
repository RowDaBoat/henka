import bindings

var logger: Logger
logger.level = "info"
logger.log("hello")
logger.warn("warning")
logger.error("err", 1.0)

var storage: Storage
discard storage.get("key")
storage.set("key", "value")
discard storage.delete("key")

var config: Config
config.host = "localhost"
config.port = 8080.0

var target: EventTarget
target.abort = "event"
target.click = "event"
target.normal = "text"

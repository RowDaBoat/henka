import bindings

var client: HttpClient
discard fetchData("http://example.com")
discard fetchCount("http://example.com")
discard ping("localhost")
discard load("/data")
discard client.get("http://example.com")
discard client.post("http://example.com", "{}")

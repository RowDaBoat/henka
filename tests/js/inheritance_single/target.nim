import std/jsffi
import bindings

var node: Node
discard node.textContent
node.appendChild(node)

var elem: Element
discard elem.innerHTML
discard elem.id
elem.setAttribute("class", "main")

var html: HTMLElement
discard html.style
discard html.className
html.addEventListener("click", proc(e: JsObject) = discard)

var readable: Readable
discard readable.read()

var writable: Writable
writable.write("data")

var readWritable: ReadWritable
readWritable.write("data")

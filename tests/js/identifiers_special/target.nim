import bindings

# Hyphenated field names — backtick quoted
var elem: ElementMap
discard elem.`annotation-xml`
discard elem.`color-profile`
discard elem.`font-face`
discard elem.normal

# Dollar signs — backtick quoted, importjs patterns escaped
var jq: JQueryLike
discard jq.`$element`
discard jq.`$$ref`
discard jq.`get$value`()
`$init`()
`$$reset`()

# Nim keywords as field names — backtick quoted by slate
var kw: Keywords
discard kw.`type`
discard kw.`object`
discard kw.`import`
discard kw.`export`
discard kw.`proc`
discard kw.`var`
discard kw.`let`
discard kw.`const`
discard kw.`yield`
discard kw.`discard`
discard kw.`end`

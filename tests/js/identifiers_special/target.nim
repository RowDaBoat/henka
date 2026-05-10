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

# Empty string literal in union — gets unnamed0 const name
setAutoFill(AutoFillBase_unnamed0)
setAutoFill(AutoFillBase_off)
setAutoFill(AutoFillBase_on)

# Trailing underscores — get numeric suffix
var tu: TrailingUnderscore
discard tu.value_0
discard tu.data_0

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

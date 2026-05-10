import std/jsffi
import bindings

# Case 1: Same return type — deduped, currently returns JsObject (could be cstring)
let c1: JsObject = getConfig(GetConfig_name_host)
let c2: JsObject = getConfig(GetConfig_name_port)
let c3: JsObject = getConfig(GetConfig_name_mode)

# Case 2: Different return types — deduped, returns JsObject
let e1: JsObject = getExtension(GetExtension_name_extA)
let e2: JsObject = getExtension(GetExtension_name_extB)
let e3: JsObject = getExtension(GetExtension_name_extC)

# Case 3: Multiple params, literal is second — synthetic on second param only
let q1: JsObject = query("mydb", Query_table_users)
let q2: JsObject = query("mydb", Query_table_posts)

# Case 5: Catchall with literals — deduped, returns JsObject
let l1: JsObject = lookup(Lookup_key_name)
let l2: JsObject = lookup(Lookup_key_age)

# Case 6: Non-literal collision — stays as separate overloads (different param types)
var extA: ExtA
var extB: ExtB
process(extA)
process(extB)

# Case 9: Single literal overload — no dedup needed, stays as normal proc
let s1: cstring = single("only")

# Case 10: Different param counts — stays as separate overloads
multi("hello")
multi("hello", 42.0)

# Case 11: Numeric literal overloads — synthetic distinct cdouble
let ch1: JsObject = getChannel(GetChannel_id_0)
let ch2: JsObject = getChannel(GetChannel_id_1)
let ch3: JsObject = getChannel(GetChannel_id_2)

# Case 12: Boolean literal overloads — synthetic distinct bool
let t1: JsObject = toggle(Toggle_state_true)
let t2: JsObject = toggle(Toggle_state_false)

# Case 7: Method overloads on interface — same dedup as free functions
var renderer: Renderer
let m1: JsObject = renderer.getFeature(Renderer_getFeature_name_EXT_A)
let m2: JsObject = renderer.getFeature(Renderer_getFeature_name_EXT_B)
let m3: JsObject = renderer.getFeature(Renderer_getFeature_name_EXT_C)

discard c1; discard c2; discard c3
discard e1; discard e2; discard e3
discard q1; discard q2
discard l1; discard l2
discard s1
discard ch1; discard ch2; discard ch3
discard t1; discard t2
discard m1; discard m2; discard m3

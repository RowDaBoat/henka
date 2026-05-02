import bindings

# builtin aliases
let i: Int32 = 0
let f: Float32 = 0.0
let u: UInt32 = 0
let b: Byte = '0'

# enum
let p: Priority = Low
let n: Named = On

# pointers
let ip: IntPtr = nil
let s: String = nil
let h: Handle = nil

# function pointers
proc cmp(a0: cint, a1: cint): cint {.cdecl.} = a0 - a1
proc noop() {.cdecl.} = discard

let c: Comparator = cmp
let cb: Callback = noop

# CDTs
var pt: Point
pt.x = 1
pt.y = 2

var v: Vec3
v.x = 1.0
v.y = 2.0
v.z = 3.0

var num: Number
num.i = 42

var t: Tagged
t.c = 'x'

# ADTs
var n3 = Node(value: 3, next: nil)
var n2 = Node(value: 2, next: addr n3)
var n1 = Node(value: 1, next: addr n2)
var list: List = addr n1

var leaf1 = TreeNode(value: 1, left: nil, right: nil)
var leaf2 = TreeNode(value: 3, left: nil, right: nil)
var root = TreeNode(value: 2, left: addr leaf1, right: addr leaf2)
var tree: Tree = addr root

import bindings

echo Red
echo Green
echo Blue

assert None is cint
assert Read is cint
assert Write is cint
assert Execute is cint
assert (Read or Write).cint == 3
assert (Read and Write).cint == 0
assert (Read or Write or Execute).cint == 7
assert (None and Execute).cint == 0

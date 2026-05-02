import bindings

echo Red
echo Green
echo Blue

static:
  assert (Read or Write).cint == 2
  assert (Read and Write).cint == 0
  assert (Read or Write or Execute).cint == 7
  assert (None and Execute).cint == 0

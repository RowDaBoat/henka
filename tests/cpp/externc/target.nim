import bindings

when not declared(should_be_declared):
  {.error: "should_be_declared not declared".}

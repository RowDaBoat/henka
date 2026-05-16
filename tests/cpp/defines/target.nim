import bindings

when declared(should_not_be_declared):
  {.error: "should_not_be_declared should not be declared".}

when not declared(should_be_declared):
  {.error: "should_be_declared should be declared".}

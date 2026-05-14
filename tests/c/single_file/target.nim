import bindings

when not declared(regular_c_function):
  {.error: "regular_c_function should be defined".}

when declared(should_not_be_defined):
  {.error: "should_not_be_defined should not be defined".}

when not declared(should_be_defined):
  {.error: "should_be_defined should be defined".}

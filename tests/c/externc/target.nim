import bindings

when not declared(regular_c_function):
  {.error: "regular_c_function should be defined".}

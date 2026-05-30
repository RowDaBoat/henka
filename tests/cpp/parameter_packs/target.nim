import bindings

doAssert combineArgs(10'i32, 1'i32, 2'i32, 3'i32) == 13
doAssert combineArgs(10'i32, 1'i32) == 11
doAssert combineArgs(10'i32) == 10

doAssert countArgs(1'i32, 2'i32, 3'i32) == 3
doAssert countArgs() == 0

echo "parameter_packs passed"

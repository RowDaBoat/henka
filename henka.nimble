# Package
version     = "0.2.0"
author      = "RowDaBoat & heysokam"
description = "Generate Nim FFI bindings from clang's AST"
license     = "MIT"
installExt  = @["nim"]

# Dependencies
requires "nim >= 2.0.0"
requires "https://github.com/RowDaBoat/cliquet#head"
requires "https://codeberg.org/heysokam/astTF#head"
requires "https://codeberg.org/heysokam/slate#head"

# Binaries
bin           = @["henka"]
srcDir        = "src"
binDir        = "bin"


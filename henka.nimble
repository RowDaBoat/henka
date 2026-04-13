# Package
version     = "0.1.0"
author      = "RowDaBoat"
description = "Generate Nim FFI bindings from Clang AST JSON"
license     = "MIT"

# Dependencies
requires "nim >= 2.0.0"
requires "https://github.com/rowDaBoat/cliquet"

# Binaries
bin           = @["henka"]
srcDir        = "src"
binDir        = "bin"
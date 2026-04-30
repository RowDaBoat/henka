import ./henka/base      ; export base
import ./henka/callbacks ; export callbacks
import ./henka/generator ; export generator

when isMainModule:
  type CliConfig = object
    help      {.help: "Show this help message", shortOption: 'h', mode: option.}           : bool
    clangargs {.help: "Forward arguments to clang".}                                       : string
    astout    {.help: "Output the generated JSON AST to this path".}                       : string
    nimout    {.help: "Output the generated Nim bindings to this path (default: stdout)".} : string
    jsonast   {.help: "Use an existing JSON AST instead of invoking clang".}               : string

  var cli = initCliquet(CliConfig())
  let headers = cli.parseOptions(commandLineParams())
  let config = cli.config()

  let usage = "Usage: henka [options] <header.h> [header.h ...]"
  let help = usage & "\n" & cli.generateHelp()
  if config.help:
    echo help
    quit(0)

  # TODO: Port the CLI application to the new API
  echo "Hello Henka: TODO"


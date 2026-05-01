import std/[os, sequtils, strutils]
import cliquet
import generator


type CliConfig = object
  help {.
    help: "Show this help message",
    shortOption: 'h',
    mode: option
  .} : bool

  clangArgs  {.
    help: "Forward arguments to clang",
    usage: "..."
  .} : string

  nimout {.
    help: "Output the generated Nim bindings to this path (default: stdout)",
    usage: "file"
  .} : string

  cpp {.
    help: "Compile using clang++",
    usage: ""
  .} : bool

  std {.
    help: "Standard used for C++",
    usage: "c++17"
  .} : string

  includeDir {.
    help: "Specify a path to an includes directory",
    usage: "path"
  .} : string

  incl {.
    help: "Include path forwarded to the compiler", shortOnly: 'I',
    usage: "path"
  .} : seq[string]

  def {.
    help: "Define forwarded to the compiler", shortOnly: 'D',
    usage: "definition[=value]"
  .} : seq[string]


proc run* =
  var cliquet = initCliquet(CliConfig())
  let rest = cliquet.parseOptions(commandLineParams())
  let config = cliquet.config()
  var usage = cliquet.generateUsage() & " header.h [... last_header.h]"

  if config.help:
    echo usage & "\n" & cliquet.generateHelp()
    quit(0)

  if rest.len != 1 or rest[0].len == 0:
    echo usage
    quit(1)

  let heaeder = rest[0]
  var extraArgs = config.clangargs.split()
  extraArgs.add config.incl.mapIt("-I" & it)
  extraArgs.add config.def.mapIt("-D" & it)
  
  if config.std != "":
    extraArgs.add "-std=" & config.std

  let isCpp = config.cpp or heaeder.splitFile.ext in [".hpp", ".hxx", ".h++", ".hh"]
  let output = generate(heaeder, extraArgs, isCpp, config.includeDir)

  echo output
  let outFile = heaeder.changeFileExt(".nim")
  outFile.writeFile(output)
  echo "\nWrote: ", outFile

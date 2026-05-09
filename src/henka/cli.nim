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

  inpath {.
    help: "Input path to find headers (default: .)",
    usage: "dir"
  .} : string

  outpath {.
    help: "Output path for the generated Nim bindings (default: the in-path)",
    usage: "dir"
  .} : string

  stdin {.
    help: "Read astTF JSON from stdin and generate Nim output",
    mode: option
  .} : bool

  cpp {.
    help: "Compile using clang++",
    usage
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
  var headers = cliquet.parseOptions(commandLineParams())
  let config  = cliquet.config()
  var usage   = cliquet.generateUsage() & " header.h [... last_header.h]"

  if config.help:
    echo usage & "\n" & cliquet.generateHelp()
    quit(0)

  if config.stdin:
    let json   = readAll(system.stdin)
    let output = generator.fromJson(json)
    for module in output.modules:
      let nimPath = module.path.changeFileExt(".nim")
      createDir(nimPath.parentDir)
      nimPath.writeFile(module.definitions)
    let outPath = case output.modules.len > 1
      of true:  output.modules[0].path.parentDir
      of false: output.modules[0].path.changeFileExt(".nim")
    echo "Done"
    echo outPath
    quit(0)

  if headers.len == 0:
    echo usage
    quit(1)

  var inpath = "."
  if config.inpath != "":
    inPath = config.inpath

  var outPath = inPath
  if (config.outpath != ""):
    outPath = config.outpath

  headers = headers.mapIt(inpath / it)

  var extraArgs = config.clangargs.split()
  extraArgs.add config.incl.mapIt("-I" & it)
  extraArgs.add config.def.mapIt("-D" & it)

  if config.std != "":
    extraArgs.add "-std=" & config.std

  let cppExt = [".hpp", ".hxx", ".h++", ".hh"]
  let isCpp  = config.cpp and headers.anyIt(it.splitFile.ext in cppExt)
  let output = generate(headers, extraArgs, inpath, isCpp)

  for module in output.modules:
    let relPath = module.path.relativePath(inpath)
    let nimPath = outPath / relPath.changeFileExt(".nim")
    createDir(nimPath.parentDir)
    nimPath.writeFile(module.definitions)
    echo "Wrote ", nimPath

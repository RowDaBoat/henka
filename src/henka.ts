import ts from "typescript"
import type { astTF } from "@heysokam/astTF"
import { convert } from "./henka/js/converter"

export { convert }

if (import.meta.main) run()
function run(): void {
  const files = process.argv.slice(2)
  if (files.length === 0) {
    console.error("Usage: henka-ts <file.ts> [... files]")
    process.exit(1)
  }

  const program = ts.createProgram(files, {
    target: ts.ScriptTarget.ESNext,
    module: ts.ModuleKind.ESNext,
    allowJs: true,
    checkJs: true,
  })

  const ast: astTF = {
    root: 0,
    data: {
      modules: [],
    },
  }

  for (const filename of files) {
    const sourceFile = program.getSourceFile(filename)
    if (!sourceFile) { console.error("Failed to parse:", filename); process.exit(1) }
    const moduleId = ast.data.modules.length
    ast.data.modules.push({ path: filename, source: "" })
    convert(ast, moduleId, sourceFile, program)
  }

  console.log(JSON.stringify(ast, null, 2))
}


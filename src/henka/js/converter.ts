import ts from "typescript"
import type { astTF } from "@heysokam/astTF"
import { statement_function, statement_class, statement_enum, statement_variable, statement_type, statement_namespace } from "./statements"
import { patchInheritableParents, resolveOverloadDedup, sortChildTypes, stitchChains } from "./postprocess"

export interface Converter {
  ast: astTF
  moduleId: number
  checker: ts.TypeChecker
  source: string
  needsJsffi: boolean
  needsAsyncjs: boolean
  needsOptions: boolean
  needsUndefined: boolean
  needsNull: boolean
  syntheticCount: number
  objectTypeIds: Map<string, number>
  emittedProcs: Map<string, { procId: number, literalsId: number | null, literalParamIdx: number, hasSelf: boolean, paramCount: number }>
  procLiterals: number[][]
  externalTypes: Map<string, number>
  uniqueNames: Map<string, number>
  namespaceStack: string[]
  firstRootTypeStmt: number | undefined
  lastRootTypeStmt: number | undefined
  firstChildTypeStmt: number | undefined
  lastChildTypeStmt: number | undefined
  firstOtherStmt: number | undefined
  lastOtherStmt: number | undefined
}

function ts_visitor(conv: Converter, node: ts.Node) {
  if (!conv.ast.data.types) conv.ast.data.types = []
  if (!conv.ast.data.expressions) conv.ast.data.expressions = []
  if (!conv.ast.data.statements) conv.ast.data.statements = []
  if (!conv.ast.data.bindings) conv.ast.data.bindings = []
  if (!conv.ast.data.procedures) conv.ast.data.procedures = []
  if (!conv.ast.data.links) conv.ast.data.links = []
  if (ts.isFunctionDeclaration(node) && node.name) statement_function(conv, node)
  if (ts.isClassDeclaration(node) && node.name) statement_class(conv, node)
  if (ts.isEnumDeclaration(node)) statement_enum(conv, node)
  if (ts.isVariableStatement(node)) statement_variable(conv, node)
  if (ts.isInterfaceDeclaration(node) || ts.isTypeAliasDeclaration(node)) statement_type(conv, node)
  if (ts.isModuleDeclaration(node) && node.name && ts.isIdentifier(node.name) && node.body) statement_namespace(conv, node)
}

export { ts_visitor }
export function convert(ast: astTF, moduleId: number, sourceFile: ts.SourceFile, program: ts.Program) {
  const conv: Converter = {
    ast,
    moduleId,
    checker: program.getTypeChecker(),
    source: "",
    needsJsffi: false,
    needsAsyncjs: false,
    needsOptions: false,
    needsUndefined: false,
    needsNull: false,
    syntheticCount: 0,
    objectTypeIds: new Map(),
    emittedProcs: new Map(),
    procLiterals: [],
    externalTypes: new Map(),
    uniqueNames: new Map(),
    namespaceStack: [],
    firstRootTypeStmt: undefined,
    lastRootTypeStmt: undefined,
    firstChildTypeStmt: undefined,
    lastChildTypeStmt: undefined,
    firstOtherStmt: undefined,
    lastOtherStmt: undefined,
  }

  ts.forEachChild(sourceFile, n => ts_visitor(conv, n))
  patchInheritableParents(conv)
  resolveOverloadDedup(conv)
  sortChildTypes(conv)
  stitchChains(conv)
  conv.ast.data.modules[conv.moduleId].source = conv.source
}


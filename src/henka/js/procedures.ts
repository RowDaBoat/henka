import ts from "typescript"
import type { Converter } from "./converter"
import { addName, sanitize, addSrc, addImportjsPragma, pushLiteralExpr, addTypeExpr, nimNormalize } from "./helpers"
import { link_statement } from "./links"
import { mapType } from "./types"


export function emitOrDedup(
  conv: Converter,
  procName: string,
  params: ts.NodeArray<ts.ParameterDeclaration>,
  retTypeNode: ts.TypeNode | undefined,
  pattern: string,
  selfType?: number,
  typeParams?: readonly ts.TypeParameterDeclaration[],
  dedupKey?: string,
): void {
  const mapKey = dedupKey ?? procName
  const existing = conv.emittedProcs.get(mapKey)
  const literalParamIdx = params.findIndex(p => p.type && ts.isLiteralTypeNode(p.type))
  const literalParam = literalParamIdx >= 0 ? params[literalParamIdx] : undefined

  if (existing && literalParam && existing.literalsId !== null && existing.paramCount === params.length) {
    const literalNode = (literalParam.type as ts.LiteralTypeNode).literal
    conv.procLiterals[existing.literalsId].push(pushLiteralExpr(conv, literalNode))
  } else {
    addProc(conv, procName, params, retTypeNode, pattern, selfType, typeParams)
    const procId = conv.ast.data.procedures.length - 1
    let literalsId: number | null = null
    if (literalParam) {
      const literalNode = (literalParam.type as ts.LiteralTypeNode).literal
      literalsId = conv.procLiterals.length
      conv.procLiterals.push([pushLiteralExpr(conv, literalNode)])
    }
    conv.emittedProcs.set(mapKey, { procId, literalsId, literalParamIdx, hasSelf: selfType !== undefined, paramCount: params.length })
  }
}


export function addProc(
  conv: Converter,
  name: string,
  params: ts.NodeArray<ts.ParameterDeclaration>,
  retTypeNode: ts.TypeNode | undefined,
  pattern: string,
  selfType?: number,
  typeParams?: readonly ts.TypeParameterDeclaration[],
) {
  if (!conv.ast.data.expressions) conv.ast.data.expressions = []
  if (!conv.ast.data.bindings) conv.ast.data.bindings = []
  if (!conv.ast.data.procedures) conv.ast.data.procedures = []
  if (!conv.ast.data.statements) conv.ast.data.statements = []
  conv.nimNames.add(nimNormalize(name))
  const funcName = addName(conv, name)
  let retType: number | undefined
  if (retTypeNode) {
    const isThisType = retTypeNode.kind === ts.SyntaxKind.ThisType
    const retTypeId = (isThisType && selfType !== undefined) ? selfType : mapType(conv, retTypeNode)
    retType = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: retTypeId } })
  }

  let firstArg: number | undefined
  let prevArg: number | undefined

  // Add self parameter for instance methods
  if (selfType !== undefined) {
    const selfName = addName(conv, "self")
    const selfTypeExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: selfType } })
    const bindingId = conv.ast.data.bindings.length
    conv.ast.data.bindings.push({ name: selfName, dataType: selfTypeExpr, private: true })
    firstArg = bindingId
    prevArg = bindingId
  }

  for (const param of params) {
    const argName = addName(conv, sanitize(conv, param.name.getText()))
    let argTypeId: number
    if (param.dotDotDotToken && param.type && ts.isArrayTypeNode(param.type)) {
      const elemTypeId = mapType(conv, param.type.elementType)
      conv.ast.data.types.push({ array: { name: addName(conv, "varargs"), element: elemTypeId } })
      argTypeId = conv.ast.data.types.length - 1
    } else {
      argTypeId = mapType(conv, param.type)
    }
    if (param.questionToken) {
      conv.ast.data.types.push({ array: { name: addName(conv, "Option"), element: argTypeId } })
      argTypeId = conv.ast.data.types.length - 1
      conv.needsOptions = true
    }
    let defaultValueId: number | undefined
    if (param.initializer) {
      if (ts.isNumericLiteral(param.initializer)) {
        defaultValueId = conv.ast.data.expressions.length
        conv.ast.data.expressions.push({ literal: { kind: 1, value: addSrc(conv, param.initializer.text) } })
      } else if (ts.isStringLiteral(param.initializer)) {
        defaultValueId = conv.ast.data.expressions.length
        conv.ast.data.expressions.push({ literal: { kind: 2, value: addSrc(conv, param.initializer.text) } })
      } else if (param.initializer.kind === ts.SyntaxKind.TrueKeyword) {
        defaultValueId = conv.ast.data.expressions.length
        conv.ast.data.expressions.push({ literal: { kind: 4, value: addSrc(conv, "true") } })
      } else if (param.initializer.kind === ts.SyntaxKind.FalseKeyword) {
        defaultValueId = conv.ast.data.expressions.length
        conv.ast.data.expressions.push({ literal: { kind: 4, value: addSrc(conv, "false") } })
      }
    }
    const argTypeExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: argTypeId } })
    const bindingId = conv.ast.data.bindings.length
    conv.ast.data.bindings.push({ name: argName, dataType: argTypeExpr, private: true, value: defaultValueId })
    if (prevArg !== undefined) conv.ast.data.bindings[prevArg].next = bindingId
    if (firstArg === undefined) firstArg = bindingId
    prevArg = bindingId
  }

  let pragmaId = addImportjsPragma(conv, pattern)
  if (retTypeNode && retTypeNode.kind === ts.SyntaxKind.UndefinedKeyword) {
    const discardableKey = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ identifier: { name: addName(conv, "discardable") } })
    const discardableId = conv.ast.data.pragmas.length
    conv.ast.data.pragmas.push({ key: discardableKey, next: pragmaId })
    pragmaId = discardableId
  }
  let firstGeneric: number | undefined
  if (typeParams && typeParams.length > 0) {
    let prevGeneric: number | undefined
    for (const tp of typeParams) {
      const genericName = addName(conv, tp.name.text)
      const genericId = conv.ast.data.bindings.length
      conv.ast.data.bindings.push({ name: genericName, private: true })
      if (prevGeneric !== undefined) conv.ast.data.bindings[prevGeneric].next = genericId
      if (firstGeneric === undefined) firstGeneric = genericId
      prevGeneric = genericId
    }
  }

  const procId = conv.ast.data.procedures.length
  conv.ast.data.procedures.push({
    name: funcName,
    generics: firstGeneric,
    arguments: firstArg,
    returnType: retType,
    pragmas: pragmaId,
    impure: true,
  })

  const stmtId = conv.ast.data.statements.length
  conv.ast.data.statements.push({ procedure: { id: procId } })
  link_statement(conv, stmtId)
}


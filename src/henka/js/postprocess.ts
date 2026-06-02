import ts from "typescript"
import type { Converter } from "./converter"
import { addName, addSrc, sanitize, addTypeExpr, addImportjsPragma, addInheritablePragma } from "./helpers"
import { link_after, link_statement, link_statement_type_root } from "./links"


export function patchInheritableParents(conv: Converter) {
  for (const typeEntry of conv.ast.data.types) {
    if (!typeEntry.object?.link) continue
    const linkRange = typeEntry.object.link
    for (let linkIdx = linkRange.start; linkIdx <= linkRange.end; linkIdx++) {
      const parentTypeId = conv.ast.data.links[linkIdx].type
      const parentType = conv.ast.data.types[parentTypeId]
      if (!parentType.primitive) continue
      const parentName = conv.source.substring(parentType.primitive.name.location.start, parentType.primitive.name.location.end)
      const parentObjectId = conv.objectTypeIds.get(parentName)
      if (parentObjectId === undefined) continue
      const parentObj = conv.ast.data.types[parentObjectId]
      if (!parentObj.object || parentObj.object.pragmas) continue
      parentObj.object.pragmas = addInheritablePragma(conv)
    }
  }
}


export function resolveOverloadDedup(conv: Converter) {
  for (const [procName, { procId, literalsId, literalParamIdx, hasSelf }] of conv.emittedProcs) {
    if (literalsId === null) continue
    const literals = conv.procLiterals[literalsId]
    if (literals.length <= 1) continue
    const proc = conv.ast.data.procedures[procId]
    if (proc.arguments === undefined) continue

    let paramBindingId: number = proc.arguments
    const skipCount = literalParamIdx + (hasSelf ? 1 : 0)
    for (let idx = 0; idx < skipCount; idx++) {
      const next = conv.ast.data.bindings[paramBindingId].next
      if (next === undefined) break
      paramBindingId = next
    }
    const paramBinding = conv.ast.data.bindings[paramBindingId]
    const paramNameLoc = paramBinding.name?.location
    const paramName = paramNameLoc ? conv.source.substring(paramNameLoc.start, paramNameLoc.end) : "param"

    const firstLiteral = conv.ast.data.expressions[literals[0]]
    const literalKind = firstLiteral.literal.kind
    const baseTypeName = literalKind === 2 ? "cstring" : literalKind === 1 ? "cdouble" : "bool"

    const baseName = procName.replace(".", "_")
    const syntheticName = baseName.charAt(0).toUpperCase() + baseName.slice(1) + "_" + paramName

    const baseTypeId = conv.ast.data.types.length
    conv.ast.data.types.push({ primitive: { name: addName(conv, baseTypeName), keyword: addName(conv, "distinct") } })
    const aliasTypeId = conv.ast.data.types.length
    conv.ast.data.types.push({ alias: { name: addName(conv, syntheticName), target: addTypeExpr(conv, baseTypeId) } })
    const typeStmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ type: { id: aliasTypeId } })
    link_statement_type_root(conv, typeStmtId)

    const syntheticRefTypeId = conv.ast.data.types.length
    conv.ast.data.types.push({ primitive: { name: addName(conv, syntheticName) } })
    const syntheticTypeExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: syntheticRefTypeId } })
    paramBinding.dataType = syntheticTypeExpr

    conv.needsJsffi = true
    const jsObjectTypeId = conv.ast.data.types.length
    conv.ast.data.types.push({ primitive: { name: addName(conv, "JsObject") } })
    const jsObjectExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: jsObjectTypeId } })
    conv.ast.data.procedures[procId].returnType = jsObjectExpr

    for (const literalExprId of literals) {
      const litExpr = conv.ast.data.expressions[literalExprId]
      const litLoc = litExpr.literal.value
      const litText = conv.source.substring(litLoc.start, litLoc.end)
      const constName = addName(conv, sanitize(conv, syntheticName + "_" + litText))
      const argBindingId = conv.ast.data.bindings.length
      conv.ast.data.bindings.push({ value: literalExprId, private: true })
      const castNameExpr = conv.ast.data.expressions.length
      conv.ast.data.expressions.push({ identifier: { name: addName(conv, syntheticName) } })
      const callExprId = conv.ast.data.expressions.length
      conv.ast.data.expressions.push({ call: { name: castNameExpr, arguments: argBindingId } })
      const constTypeId = conv.ast.data.types.length
      conv.ast.data.types.push({ primitive: { name: addName(conv, syntheticName) } })
      const constTypeExpr = conv.ast.data.expressions.length
      conv.ast.data.expressions.push({ type: { id: constTypeId } })
      const constBindingId = conv.ast.data.bindings.length
      conv.ast.data.bindings.push({ name: constName, dataType: constTypeExpr, value: callExprId })
      const constStmtId = conv.ast.data.statements.length
      conv.ast.data.statements.push({ variable: { id: constBindingId } })
      link_statement(conv, constStmtId)
    }
  }
}


export function sortChildTypes(conv: Converter) {
  if (conv.firstChildTypeStmt === undefined) return
  const children: number[] = []
  let walk: number | undefined = conv.firstChildTypeStmt
  while (walk !== undefined) {
    children.push(walk)
    walk = conv.ast.data.statements[walk].type?.next
  }

  const nameToIdx = new Map<string, number>()
  for (let idx = 0; idx < children.length; idx++) {
    const typeData = conv.ast.data.types[conv.ast.data.statements[children[idx]].type!.id]
    const loc = typeData.object?.name?.location ?? typeData.alias?.name?.location
    if (loc) nameToIdx.set(conv.source.slice(loc.start, loc.end), idx)
  }

  const sorted: number[] = []
  const visited = new Set<number>()
  function topoVisit(idx: number) {
    if (visited.has(idx)) return
    visited.add(idx)
    const typeData = conv.ast.data.types[conv.ast.data.statements[children[idx]].type!.id]
    if (typeData.object?.link && conv.ast.data.links) {
      for (let linkIdx = typeData.object.link.start; linkIdx <= typeData.object.link.end; linkIdx++) {
        const parentType = conv.ast.data.types[conv.ast.data.links[linkIdx].type]
        const parentLoc = parentType.object?.name?.location ?? parentType.primitive?.name?.location
        if (parentLoc) {
          const parentIdx = nameToIdx.get(conv.source.slice(parentLoc.start, parentLoc.end))
          if (parentIdx !== undefined) topoVisit(parentIdx)
        }
      }
    }
    sorted.push(children[idx])
  }
  for (let idx = 0; idx < children.length; idx++) topoVisit(idx)

  for (let idx = 0; idx < sorted.length - 1; idx++) conv.ast.data.statements[sorted[idx]].type!.next = sorted[idx + 1]
  delete conv.ast.data.statements[sorted[sorted.length - 1]].type!.next
  conv.firstChildTypeStmt = sorted[0]
  conv.lastChildTypeStmt = sorted[sorted.length - 1]
}

export function stitchChains(conv: Converter) {
  if (conv.lastRootTypeStmt !== undefined && conv.firstChildTypeStmt !== undefined) {
    link_after(conv, conv.lastRootTypeStmt, conv.firstChildTypeStmt)
  }
  const lastTypeStmt = conv.lastChildTypeStmt ?? conv.lastRootTypeStmt
  if (lastTypeStmt !== undefined && conv.firstOtherStmt !== undefined) {
    link_after(conv, lastTypeStmt, conv.firstOtherStmt)
  }
  if (conv.needsNull) {
    const distinctId = conv.ast.data.types.length
    conv.ast.data.types.push({ primitive: { name: addName(conv, "JsObject"), keyword: addName(conv, "distinct") } })
    const aliasId = conv.ast.data.types.length
    conv.ast.data.types.push({ alias: { name: addName(conv, "Null"), target: addTypeExpr(conv, distinctId) } })
    const stmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ type: { id: aliasId, next: conv.firstRootTypeStmt } })
    conv.firstRootTypeStmt = stmtId
    conv.needsJsffi = true
  }

  if (conv.needsUndefined) {
    const ptrId = conv.ast.data.types.length
    conv.ast.data.types.push({ primitive: { name: addName(conv, "pointer"), keyword: addName(conv, "distinct") } })
    const aliasId = conv.ast.data.types.length
    conv.ast.data.types.push({ alias: { name: addName(conv, "Undefined"), target: addTypeExpr(conv, ptrId) } })
    const stmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ type: { id: aliasId, next: conv.firstRootTypeStmt } })
    conv.firstRootTypeStmt = stmtId
  }

  const firstTypeStmt = conv.firstRootTypeStmt ?? conv.firstChildTypeStmt
  conv.ast.data.modules[conv.moduleId].body = firstTypeStmt ?? conv.firstOtherStmt

  if (conv.needsOptions) {
    const keyword = addName(conv, "import")
    const path = addSrc(conv, "std/options")
    const importStmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ import: { keyword, path, next: conv.ast.data.modules[conv.moduleId].body } })
    conv.ast.data.modules[conv.moduleId].body = importStmtId
  }

  if (conv.needsAsyncjs) {
    const keyword = addName(conv, "import")
    const path = addSrc(conv, "std/asyncjs")
    const importStmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ import: { keyword, path, next: conv.ast.data.modules[conv.moduleId].body } })
    conv.ast.data.modules[conv.moduleId].body = importStmtId
  }

  if (conv.needsJsffi) {
    const keyword = addName(conv, "import")
    const path = addSrc(conv, "std/jsffi")
    const importStmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ import: { keyword, path, next: conv.ast.data.modules[conv.moduleId].body } })
    conv.ast.data.modules[conv.moduleId].body = importStmtId
  }
}


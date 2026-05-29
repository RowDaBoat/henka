import ts from "typescript"
import type { Converter } from "./converter"

export function unquote(name: string): string {
  if ((name.startsWith('"') && name.endsWith('"')) || (name.startsWith("'") && name.endsWith("'")))
    return name.slice(1, -1)
  return name
}


export function nimNormalize(name: string): string {
  if (name.length === 0) return ""
  return name[0].toLowerCase() + name.slice(1).replace(/_/g, "").toLowerCase()
}


export function uniqueNimName(conv: Converter, name: string): string {
  let candidate = name
  let counter = 2
  while (conv.nimNames.has(nimNormalize(candidate))) {
    candidate = name + String(counter)
    counter++
  }
  return candidate
}


export function addSrc(conv: Converter, text: string) {
  const start = conv.source.length
  conv.source += text
  return { start, end: conv.source.length }
}


export function sanitize(conv: Converter, name: string): string {
  if (name.length === 0) {
    const count = conv.uniqueNames.get("unnamed") ?? 0
    conv.uniqueNames.set("unnamed", count + 1)
    return "unnamed" + count
  }
  let result = name
  result = result.replace(/[^a-zA-Z0-9_]/g, "")
  if (result.length === 0) {
    const count = conv.uniqueNames.get("unnamed") ?? 0
    conv.uniqueNames.set("unnamed", count + 1)
    return "unnamed" + count
  }
  if (/^[0-9]/.test(result)) result = "field" + result
  if (result.startsWith("__")) result = "internal" + result.slice(1)
  else if (result.startsWith("_")) result = "priv" + result
  result = result.replace(/_{2,}/g, "_")
  if (result.endsWith("_")) {
    const count = conv.uniqueNames.get(result) ?? 0
    conv.uniqueNames.set(result, count + 1)
    result = result + count
  }
  return result
}


export function prefixed(conv: Converter, name: string): string {
  const sanitized = sanitize(conv, name)
  if (conv.namespaceStack.length === 0) return sanitized
  return conv.namespaceStack.join("_") + "_" + sanitized
}


export function jsPattern(conv: Converter, name: string): string {
  if (conv.namespaceStack.length === 0) return name
  return conv.namespaceStack.join(".") + "." + name
}


export function addName(conv: Converter, text: string) {
  return { location: addSrc(conv, text) }
}


export function addInheritablePragma(conv: Converter): number {
  if (!conv.ast.data.expressions) conv.ast.data.expressions = []
  if (!conv.ast.data.pragmas) conv.ast.data.pragmas = []
  const keyExpr = conv.ast.data.expressions.length
  conv.ast.data.expressions.push({ identifier: { name: addName(conv, "inheritable") } })
  const pragmaId = conv.ast.data.pragmas.length
  conv.ast.data.pragmas.push({ key: keyExpr })
  return pragmaId
}


export function addTypeExpr(conv: Converter, typeId: number): number {
  if (!conv.ast.data.expressions) conv.ast.data.expressions = []
  const exprId = conv.ast.data.expressions.length
  conv.ast.data.expressions.push({ type: { id: typeId } })
  return exprId
}


export function addImportjsPragma(conv: Converter, pattern: string): number {
  if (!conv.ast.data.expressions) conv.ast.data.expressions = []
  if (!conv.ast.data.pragmas) conv.ast.data.pragmas = []
  const escaped = pattern.replace(/\$/g, "$$$$")
  const keyExpr = conv.ast.data.expressions.length
  conv.ast.data.expressions.push({ identifier: { name: addName(conv, "importjs") } })
  const valExpr = conv.ast.data.expressions.length
  conv.ast.data.expressions.push({ literal: { kind: 2, value: addSrc(conv, escaped) } })
  const pragmaId = conv.ast.data.pragmas.length
  conv.ast.data.pragmas.push({ key: keyExpr, value: valExpr })
  return pragmaId
}


export function pushLiteralExpr(conv: Converter, literalNode: ts.Node): number {
  const exprId = conv.ast.data.expressions.length
  if (ts.isStringLiteral(literalNode))
    conv.ast.data.expressions.push({ literal: { kind: 2, value: addSrc(conv, literalNode.text) } })
  else if (ts.isNumericLiteral(literalNode))
    conv.ast.data.expressions.push({ literal: { kind: 1, value: addSrc(conv, literalNode.text) } })
  else if (literalNode.kind === ts.SyntaxKind.TrueKeyword)
    conv.ast.data.expressions.push({ literal: { kind: 4, value: addSrc(conv, "true") } })
  else if (literalNode.kind === ts.SyntaxKind.FalseKeyword)
    conv.ast.data.expressions.push({ literal: { kind: 4, value: addSrc(conv, "false") } })
  else
    conv.ast.data.expressions.push({ literal: { kind: 2, value: addSrc(conv, literalNode.getText()) } })
  return exprId
}


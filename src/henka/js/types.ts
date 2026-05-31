import ts from "typescript"
import type { Binding } from "@heysokam/astTF"
import type { Converter } from "./converter"
import { addName, addSrc, sanitize, addTypeExpr, addImportjsPragma, unquote } from "./helpers"
import { link_statement, link_statement_type_root } from "./links"

function type_reference(conv: Converter, node: ts.TypeReferenceNode, typeText: string): number {
  const refName = node.typeName.getText()
  if (refName === "Array" && node.typeArguments && node.typeArguments.length === 1) {
    const elemTypeId = mapType(conv, node.typeArguments[0])
    conv.ast.data.types.push({ array: { name: addName(conv, "seq"), element: elemTypeId } })
    return conv.ast.data.types.length - 1
  }
  if (refName === "Promise" && node.typeArguments && node.typeArguments.length === 1) {
    const innerTypeId = mapType(conv, node.typeArguments[0])
    conv.ast.data.types.push({ array: { name: addName(conv, "Future"), element: innerTypeId } })
    conv.needsAsyncjs = true
    return conv.ast.data.types.length - 1
  }
  if (node.typeArguments && node.typeArguments.length > 0) {
    conv.ast.data.types.push({ primitive: { name: addName(conv, "JsObject") } })
    conv.needsJsffi = true
    return conv.ast.data.types.length - 1
  }

  const symbol          = conv.checker.getSymbolAtLocation(node.typeName)
  const hasDeclarations = symbol?.declarations && symbol.declarations.length > 0
  const declFile        = hasDeclarations ? symbol.declarations[0].getSourceFile().fileName : undefined
  const inputFiles      = conv.ast.data.modules.map(m => m.path.replace(/^\.\//, ""))
  const isExternal      = !symbol || !hasDeclarations || (declFile !== undefined && !inputFiles.includes(declFile.replace(/^\.\//, "")))

  if (isExternal) {
    const existing = conv.externalTypes.get(typeText)
    if (existing !== undefined) {
      conv.ast.data.types.push({ primitive: { name: addName(conv, sanitize(conv, typeText)) } })
    } else {
      conv.needsJsffi = true
      const jsObjectId = conv.ast.data.types.length
      conv.ast.data.types.push({ primitive: { name: addName(conv, "JsObject") } })
      const aliasId = conv.ast.data.types.length
      conv.ast.data.types.push({ alias: { name: addName(conv, sanitize(conv, typeText)), target: addTypeExpr(conv, jsObjectId) } })
      const stmtId = conv.ast.data.statements.length
      conv.ast.data.statements.push({ type: { id: aliasId } })
      link_statement_type_root(conv, stmtId)
      conv.externalTypes.set(typeText, aliasId)
      conv.ast.data.types.push({ primitive: { name: addName(conv, sanitize(conv, typeText)) } })
    }
    return conv.ast.data.types.length - 1
  }

  let resolvedName = typeText
  const isTypeParam = symbol.declarations?.some(d => ts.isTypeParameterDeclaration(d)) ?? false
  if (isTypeParam) {
    conv.ast.data.types.push({ primitive: { name: addName(conv, resolvedName) } })
    return conv.ast.data.types.length - 1
  }
  let fullName = conv.checker.getFullyQualifiedName(symbol)
  const quoteEnd = fullName.lastIndexOf('"')
  if (quoteEnd >= 0) fullName = fullName.substring(quoteEnd + 2)
  if (fullName.includes(".")) resolvedName = fullName.replace(/\./g, "_")
  conv.ast.data.types.push({ primitive: { name: addName(conv, sanitize(conv, resolvedName)) } })
  return conv.ast.data.types.length - 1
}

function type_function(conv: Converter, node: ts.FunctionTypeNode): number {
  const retTypeId = mapType(conv, node.type)
  const retTypeExpr = conv.ast.data.expressions.length
  conv.ast.data.expressions.push({ type: { id: retTypeId } })

  let firstArg: number | undefined
  let prevArg: number | undefined
  for (const param of node.parameters) {
    if (param.name.getText() === "this") continue
    const argName = addName(conv, sanitize(conv, param.name.getText()))
    const argTypeId = mapType(conv, param.type)
    const argTypeExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: argTypeId } })
    const bindingId = conv.ast.data.bindings.length
    conv.ast.data.bindings.push({ name: argName, dataType: argTypeExpr, private: true })
    if (prevArg !== undefined) conv.ast.data.bindings[prevArg].next = bindingId
    if (firstArg === undefined) firstArg = bindingId
    prevArg = bindingId
  }

  const procId = conv.ast.data.procedures.length
  conv.ast.data.procedures.push({
    arguments: firstArg,
    returnType: retTypeExpr,
    impure: true,
    private: true,
  })
  conv.ast.data.types.push({ procedure: { id: procId } })
  return conv.ast.data.types.length - 1
}

function type_inline(conv: Converter, node: ts.TypeLiteralNode): number {
  const members = node.members
  let firstField: number | undefined
  let prevField: number | undefined
  for (const member of members) {
    if (!ts.isPropertySignature(member) || !member.name) continue
    const fieldName = addName(conv, sanitize(conv, unquote(member.name.getText())))
    let fieldTypeId = mapType(conv, member.type)
    if (member.questionToken) {
      conv.ast.data.types.push({ array: { name: addName(conv, "Option"), element: fieldTypeId } })
      fieldTypeId = conv.ast.data.types.length - 1
      conv.needsOptions = true
    }
    const fieldTypeExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: fieldTypeId } })
    const bindingId = conv.ast.data.bindings.length
    conv.ast.data.bindings.push({ name: fieldName, dataType: fieldTypeExpr })
    if (prevField !== undefined) conv.ast.data.bindings[prevField].next = bindingId
    if (firstField === undefined) firstField = bindingId
    prevField = bindingId
  }
  const syntheticName = "Anonymous" + conv.syntheticCount++
  const objectTypeId = conv.ast.data.types.length
  conv.ast.data.types.push({ object: { name: addName(conv, syntheticName), fields: firstField } })
  conv.objectTypeIds.set(syntheticName, objectTypeId)
  const stmtId = conv.ast.data.statements.length
  conv.ast.data.statements.push({ type: { id: objectTypeId } })
  link_statement(conv, stmtId)
  conv.ast.data.types.push({ primitive: { name: addName(conv, syntheticName) } })
  return conv.ast.data.types.length - 1
}

function type_union(conv: Converter, node: ts.UnionTypeNode): number {
  const nonUndefined = node.types.filter(t =>
    t.kind !== ts.SyntaxKind.UndefinedKeyword &&
    !(ts.isLiteralTypeNode(t) && t.literal.kind === ts.SyntaxKind.NullKeyword)
  )
  if (nonUndefined.length === 1) {
    const innerTypeId = mapType(conv, nonUndefined[0])
    conv.ast.data.types.push({ array: { name: addName(conv, "Option"), element: innerTypeId } })
    conv.needsOptions = true
  } else {
    conv.ast.data.types.push({ primitive: { name: addName(conv, "JsObject") } })
    conv.needsJsffi = true
  }
  return conv.ast.data.types.length - 1
}

function type_literal(conv: Converter, node: ts.LiteralTypeNode, typeText: string): number {
  const literal = node.literal
  if (literal.kind === ts.SyntaxKind.StringLiteral) {
    conv.ast.data.types.push({ primitive: { name: addName(conv, "cstring") } })
  } else if (literal.kind === ts.SyntaxKind.NumericLiteral ||
    (literal.kind === ts.SyntaxKind.PrefixUnaryExpression &&
      ts.isNumericLiteral((literal as ts.PrefixUnaryExpression).operand))) {
    conv.ast.data.types.push({ primitive: { name: addName(conv, "cdouble") } })
  } else if (literal.kind === ts.SyntaxKind.TrueKeyword ||
    literal.kind === ts.SyntaxKind.FalseKeyword) {
    conv.ast.data.types.push({ primitive: { name: addName(conv, "bool") } })
  } else if (literal.kind === ts.SyntaxKind.NullKeyword) {
    conv.ast.data.types.push({ primitive: { name: addName(conv, "Null") } })
    conv.needsNull = true
  } else {
    conv.ast.data.types.push({ primitive: { name: addName(conv, typeText) } })
  }
  return conv.ast.data.types.length - 1
}

function type_tuple(conv: Converter, node: ts.TupleTypeNode): number {
  let firstField: number | undefined
  let prevField: number | undefined
  for (const elem of node.elements) {
    const isNamed = ts.isNamedTupleMember(elem)
    const typeNode = isNamed ? (elem as ts.NamedTupleMember).type : elem
    const elemTypeId = mapType(conv, typeNode)
    const elemTypeExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: elemTypeId } })
    const binding: Binding = { dataType: elemTypeExpr }
    if (isNamed) binding.name = addName(conv, (elem as ts.NamedTupleMember).name.getText())
    const bindingId = conv.ast.data.bindings.length
    conv.ast.data.bindings.push(binding)
    if (prevField !== undefined) conv.ast.data.bindings[prevField].next = bindingId
    if (firstField === undefined) firstField = bindingId
    prevField = bindingId
  }
  conv.ast.data.types.push({ object: { keyword: addName(conv, "tuple"), fields: firstField } })
  return conv.ast.data.types.length - 1
}

function type_expressionWithArgs(conv: Converter, node: ts.ExpressionWithTypeArguments): number {
  const baseName = node.expression.getText(node.getSourceFile())
  const typeId = conv.ast.data.types.length
  conv.ast.data.types.push({ primitive: { name: addName(conv, sanitize(conv, baseName)) } })
  if (node.typeArguments && node.typeArguments.length > 0) {
    let firstExpr: number | undefined
    let prevExpr: number | undefined
    for (const arg of node.typeArguments) {
      const argTypeId = mapType(conv, arg)
      const exprId = conv.ast.data.expressions.length
      conv.ast.data.expressions.push({ type: { id: argTypeId } })
      if (prevExpr !== undefined) conv.ast.data.expressions[prevExpr].type.next = exprId
      if (firstExpr === undefined) firstExpr = exprId
      prevExpr = exprId
    }
    conv.ast.data.types[typeId].primitive.instantiation = firstExpr
  }
  return typeId
}

export function mapType(conv: Converter, node: ts.TypeNode | undefined): number {
  if (!conv.ast.data.types) conv.ast.data.types = []
  if (!conv.ast.data.expressions) conv.ast.data.expressions = []
  if (!conv.ast.data.bindings) conv.ast.data.bindings = []
  if (!conv.ast.data.statements) conv.ast.data.statements = []
  if (!conv.ast.data.procedures) conv.ast.data.procedures = []
  if (!node) {
    conv.ast.data.types.push({ primitive: { name: addName(conv, "void") } })
    return conv.ast.data.types.length - 1
  }

  const typeText = node.getText()

  switch (node.kind) {
    case ts.SyntaxKind.NumberKeyword:
      conv.ast.data.types.push({ primitive: { name: addName(conv, "cdouble") } })
      return conv.ast.data.types.length - 1
    case ts.SyntaxKind.StringKeyword:
      conv.ast.data.types.push({ primitive: { name: addName(conv, "cstring") } })
      return conv.ast.data.types.length - 1
    case ts.SyntaxKind.BooleanKeyword:
      conv.ast.data.types.push({ primitive: { name: addName(conv, "bool") } })
      return conv.ast.data.types.length - 1
    case ts.SyntaxKind.VoidKeyword:
    case ts.SyntaxKind.NeverKeyword:
      conv.ast.data.types.push({ primitive: { name: addName(conv, "void") } })
      return conv.ast.data.types.length - 1
    case ts.SyntaxKind.UndefinedKeyword:
      conv.ast.data.types.push({ primitive: { name: addName(conv, "Undefined") } })
      conv.needsUndefined = true
      return conv.ast.data.types.length - 1
    case ts.SyntaxKind.BigIntKeyword:
      conv.ast.data.types.push({ primitive: { name: addName(conv, "BiggestInt") } })
      return conv.ast.data.types.length - 1
    case ts.SyntaxKind.TemplateLiteralType:
      conv.ast.data.types.push({ primitive: { name: addName(conv, "cstring") } })
      return conv.ast.data.types.length - 1
    case ts.SyntaxKind.ThisType:
    case ts.SyntaxKind.AnyKeyword:
    case ts.SyntaxKind.ObjectKeyword:
    case ts.SyntaxKind.UnknownKeyword:
    case ts.SyntaxKind.TypeOperator:
    case ts.SyntaxKind.IndexedAccessType:
    case ts.SyntaxKind.IntersectionType:
      conv.ast.data.types.push({ primitive: { name: addName(conv, "JsObject") } })
      conv.needsJsffi = true
      return conv.ast.data.types.length - 1
    case ts.SyntaxKind.ParenthesizedType:
      return mapType(conv, (node as ts.ParenthesizedTypeNode).type)
    case ts.SyntaxKind.ArrayType: {
      const elemTypeId = mapType(conv, (node as ts.ArrayTypeNode).elementType)
      conv.ast.data.types.push({ array: { name: addName(conv, "seq"), element: elemTypeId } })
      return conv.ast.data.types.length - 1
    }
    case ts.SyntaxKind.TypeReference: return type_reference(conv, node as ts.TypeReferenceNode, typeText)
    case ts.SyntaxKind.FunctionType: return type_function(conv, node as ts.FunctionTypeNode)
    case ts.SyntaxKind.TypeLiteral: return type_inline(conv, node as ts.TypeLiteralNode)
    case ts.SyntaxKind.UnionType: return type_union(conv, node as ts.UnionTypeNode)
    case ts.SyntaxKind.LiteralType: return type_literal(conv, node as ts.LiteralTypeNode, typeText)
    case ts.SyntaxKind.TupleType: return type_tuple(conv, node as ts.TupleTypeNode)
    case ts.SyntaxKind.ExpressionWithTypeArguments: return type_expressionWithArgs(conv, node as ts.ExpressionWithTypeArguments)
    default:
      conv.ast.data.types.push({ primitive: { name: addName(conv, typeText) } })
      return conv.ast.data.types.length - 1
  }
}


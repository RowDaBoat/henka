import ts from "typescript"
import type { Converter } from "./converter"
import { addName, sanitize, prefixed, jsPattern, unquote, addSrc, addTypeExpr, addImportjsPragma, addInheritablePragma, nimNormalize, uniqueNimName } from "./helpers"
import { link_statement } from "./links"
import { mapType } from "./types"
import { emitOrDedup, addProc } from "./procedures"
import { ts_visitor } from "./converter"


export function statement_function(conv: Converter, node: ts.Node) {
  if (!ts.isFunctionDeclaration(node) || !node.name) return
  const symbol = conv.checker.getSymbolAtLocation(node.name)
  const isOverloadImpl = node.body && symbol && (symbol.declarations?.length ?? 0) > 1
  if (isOverloadImpl) return
  emitOrDedup(conv, prefixed(conv, node.name.text), node.parameters, node.type, jsPattern(conv, node.name.text) + "(@)", undefined, node.typeParameters)
}


export function statement_class(conv: Converter, node: ts.Node) {
  if (!ts.isClassDeclaration(node) || !node.name) return
  const className = node.name.text
  const prefixedClassName = prefixed(conv, className)
  const jsClassName = jsPattern(conv, className)

  conv.needsJsffi = true
  conv.ast.data.types.push({ primitive: { name: addName(conv, "JsObject"), keyword: addName(conv, "distinct") } })
  const distinctTargetId = conv.ast.data.types.length - 1
  const distinctTargetExpr = addTypeExpr(conv, distinctTargetId)

  const existingAliasId = conv.externalTypes.get(className)
  let aliasId: number
  if (existingAliasId !== undefined) {
    aliasId = existingAliasId
    conv.ast.data.types[aliasId].alias.target = distinctTargetExpr
  } else {
    aliasId = conv.ast.data.types.length
    conv.ast.data.types.push({ alias: { name: addName(conv, prefixedClassName), target: distinctTargetExpr } })
    conv.nimNames.add(nimNormalize(prefixedClassName))
    const typeStmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ type: { id: aliasId } })
    link_statement(conv, typeStmtId)
  }

  // Collect own member names for naming priority
  const ownMemberNames = new Set<string>()
  for (const member of node.members) {
    if (ts.isMethodDeclaration(member) && member.name) ownMemberNames.add(member.name.getText())
    if (ts.isPropertyDeclaration(member) && member.name) ownMemberNames.add(unquote(member.name.getText()))
  }

  // Emit field getter procs (own + inherited)
  const classType = conv.checker.getTypeAtLocation(node)
  const allProperties = conv.checker.getPropertiesOfType(classType)
  for (const prop of allProperties) {
    const declarations = prop.getDeclarations()
    if (!declarations || declarations.length === 0) continue
    const declaration = declarations[0]
    if (!ts.isPropertyDeclaration(declaration) && !ts.isPropertySignature(declaration)) continue
    const rawFieldName = prop.name
    let fieldName = sanitize(conv, rawFieldName)
    const fieldTypeId = mapType(conv, declaration.type)
    const isOwn = ownMemberNames.has(rawFieldName)
    const baseProcName = isOwn ? prefixed(conv, fieldName) : prefixedClassName + "_" + fieldName
    let procName = conv.nimNames.has(nimNormalize(baseProcName))
      ? uniqueNimName(conv, prefixedClassName + "_" + fieldName)
      : baseProcName
    conv.nimNames.add(nimNormalize(procName))
    const funcName = addName(conv, procName)
    const getterSelfTypeId = conv.ast.data.types.length
    conv.ast.data.types.push({ primitive: { name: addName(conv, prefixedClassName) } })
    const selfTypeExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: getterSelfTypeId } })
    const selfBinding = conv.ast.data.bindings.length
    conv.ast.data.bindings.push({ name: addName(conv, "self"), dataType: selfTypeExpr, private: true })
    const fieldRetExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: fieldTypeId } })
    let firstGeneric: number | undefined
    if (node.typeParameters && node.typeParameters.length > 0) {
      let prevGeneric: number | undefined
      for (const tp of node.typeParameters) {
        const genericId = conv.ast.data.bindings.length
        conv.ast.data.bindings.push({ name: addName(conv, tp.name.text), private: true })
        if (prevGeneric !== undefined) conv.ast.data.bindings[prevGeneric].next = genericId
        if (firstGeneric === undefined) firstGeneric = genericId
        prevGeneric = genericId
      }
    }
    const procId = conv.ast.data.procedures.length
    conv.ast.data.procedures.push({
      name: funcName,
      arguments: selfBinding,
      returnType: fieldRetExpr,
      generics: firstGeneric,
      impure: true,
    })
    const pragmaId = addImportjsPragma(conv, "#." + rawFieldName)
    conv.ast.data.procedures[procId].pragmas = pragmaId
    const stmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ procedure: { id: procId } })
    link_statement(conv, stmtId)
  }

  // Self type reference for methods
  const selfTypeId = conv.ast.data.types.length
  conv.ast.data.types.push({ primitive: { name: addName(conv, prefixedClassName) } })

  // Constructor
  for (const member of node.members) {
    if (!ts.isConstructorDeclaration(member)) continue
    addProc(conv, "new" + prefixedClassName, member.parameters, undefined, "new " + jsClassName + "(@)", undefined, node.typeParameters)
    const lastProc = conv.ast.data.procedures[conv.ast.data.procedures.length - 1]
    const selfRetExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: selfTypeId } })
    lastProc.returnType = selfRetExpr
    break
  }

  // Methods (own + inherited)
  for (const prop of allProperties) {
    const declarations = prop.getDeclarations()
    if (!declarations || declarations.length === 0) continue
    const declaration = declarations[0]

    if (ts.isMethodDeclaration(declaration) || ts.isMethodSignature(declaration)) {
      const methodName = prop.name
      const isStatic = declaration.modifiers?.some(m => m.kind === ts.SyntaxKind.StaticKeyword) ?? false
      if (isStatic) continue
      const pattern = "#." + methodName + "(@)"
      const baseProcName = ownMemberNames.has(methodName)
        ? prefixed(conv, methodName)
        : prefixedClassName + "_" + sanitize(conv, methodName)
      let procName = conv.nimNames.has(nimNormalize(baseProcName))
        ? uniqueNimName(conv, prefixedClassName + "_" + sanitize(conv, methodName))
        : baseProcName
      const classParamNames = new Set((node.typeParameters ?? []).map(tp => tp.name.text))
      const methodTypeParams = ('typeParameters' in declaration && declaration.typeParameters) ? [...declaration.typeParameters] : []
      const methodOnlyParams = methodTypeParams.filter(tp => !classParamNames.has(tp.name.text))
      const mergedTypeParams: ts.TypeParameterDeclaration[] = [
        ...(node.typeParameters ?? []),
        ...methodOnlyParams,
      ]
      addProc(conv, procName, declaration.parameters, declaration.type, pattern, selfTypeId, mergedTypeParams.length > 0 ? mergedTypeParams : undefined)
    }
  }

  // Property setters (own + inherited)
  for (const prop of allProperties) {
    const declarations = prop.getDeclarations()
    if (!declarations || declarations.length === 0) continue
    const declaration = declarations[0]
    if (!ts.isPropertyDeclaration(declaration) && !ts.isPropertySignature(declaration)) continue
    const isReadonly = declaration.modifiers?.some(m => m.kind === ts.SyntaxKind.ReadonlyKeyword) ?? false
    if (isReadonly) continue
    const rawFieldName = prop.name
    const sanitizedFieldName = sanitize(conv, rawFieldName)
    const fieldTypeId = mapType(conv, declaration.type)
    const setterName = "`" + sanitizedFieldName + "=`"
    const setterProcName = conv.nimNames.has(nimNormalize(prefixedClassName + "_" + sanitizedFieldName + "="))
      ? uniqueNimName(conv, prefixedClassName + "_" + sanitizedFieldName + "_setter")
      : setterName
    conv.nimNames.add(nimNormalize(setterProcName))
    const setterSelfTypeId = conv.ast.data.types.length
    conv.ast.data.types.push({ primitive: { name: addName(conv, prefixedClassName) } })
    const setterSelfExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: setterSelfTypeId } })
    const selfBindingId = conv.ast.data.bindings.length
    conv.ast.data.bindings.push({ name: addName(conv, "self"), dataType: setterSelfExpr, private: true })
    const valTypeExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: fieldTypeId } })
    const valBindingId = conv.ast.data.bindings.length
    conv.ast.data.bindings.push({ name: addName(conv, "value"), dataType: valTypeExpr, private: true })
    conv.ast.data.bindings[selfBindingId].next = valBindingId
    const pragmaId = addImportjsPragma(conv, "#." + rawFieldName + " = #")
    const procId = conv.ast.data.procedures.length
    conv.ast.data.procedures.push({
      name: addName(conv, setterProcName),
      arguments: selfBindingId,
      pragmas: pragmaId,
      impure: true,
    })
    const stmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ procedure: { id: procId } })
    link_statement(conv, stmtId)
  }
}


export function statement_enum(conv: Converter, node: ts.Node) {
  if (!ts.isEnumDeclaration(node)) return
  if (!conv.ast.data.pragmas) conv.ast.data.pragmas = []
  const enumName = prefixed(conv, node.name.text)
  conv.nimNames.add(nimNormalize(enumName))

  let firstValue: number | undefined
  let prevValue: number | undefined
  for (const member of node.members) {
    if (!member.name) continue
    const memberName = member.name.getText()
    let valueExprId: number | undefined
    if (member.initializer) {
      if (ts.isNumericLiteral(member.initializer)) {
        valueExprId = conv.ast.data.expressions.length
        conv.ast.data.expressions.push({ literal: { kind: 0, value: addSrc(conv, member.initializer.text) } })
      } else if (ts.isStringLiteral(member.initializer)) {
        valueExprId = conv.ast.data.expressions.length
        conv.ast.data.expressions.push({ literal: { kind: 2, value: addSrc(conv, member.initializer.text) } })
      }
    } else {
      const idx = node.members.indexOf(member)
      valueExprId = conv.ast.data.expressions.length
      conv.ast.data.expressions.push({ literal: { kind: 0, value: addSrc(conv, String(idx)) } })
    }
    const bindingId = conv.ast.data.bindings.length
    conv.ast.data.bindings.push({ name: addName(conv, memberName), value: valueExprId, private: true })
    if (prevValue !== undefined) conv.ast.data.bindings[prevValue].next = bindingId
    if (firstValue === undefined) firstValue = bindingId
    prevValue = bindingId
  }

  const pureKey = conv.ast.data.expressions.length
  conv.ast.data.expressions.push({ identifier: { name: addName(conv, "pure") } })
  const pragmaId = conv.ast.data.pragmas.length
  conv.ast.data.pragmas.push({ key: pureKey })

  const enumTypeId = conv.ast.data.types.length
  conv.ast.data.types.push({ enumeration: {
    name: addName(conv, enumName),
    values: firstValue,
    pragmas: pragmaId,
  } })
  const stmtId = conv.ast.data.statements.length
  conv.ast.data.statements.push({ type: { id: enumTypeId } })
  link_statement(conv, stmtId)
}


export function statement_variable(conv: Converter, node: ts.Node) {
  if (!ts.isVariableStatement(node)) return
  for (const decl of node.declarationList.declarations) {
    if (!ts.isIdentifier(decl.name)) continue
    const varPrefixed = uniqueNimName(conv, prefixed(conv, decl.name.text))
    conv.nimNames.add(nimNormalize(varPrefixed))
    const varName = addName(conv, varPrefixed)

    let valueExprId: number | undefined
    if (decl.initializer && ts.isNumericLiteral(decl.initializer)) {
      valueExprId = conv.ast.data.expressions.length
      conv.ast.data.expressions.push({
        literal: { kind: 1, value: addSrc(conv, decl.initializer.text) },
      })
    } else if (decl.initializer && ts.isPrefixUnaryExpression(decl.initializer)
      && ts.isNumericLiteral(decl.initializer.operand)) {
      valueExprId = conv.ast.data.expressions.length
      conv.ast.data.expressions.push({
        literal: { kind: 1, value: addSrc(conv, decl.initializer.getText()) },
      })
    } else if (decl.initializer && ts.isStringLiteral(decl.initializer)) {
      valueExprId = conv.ast.data.expressions.length
      conv.ast.data.expressions.push({
        literal: { kind: 2, value: addSrc(conv, decl.initializer.text) },
      })
    } else if (decl.initializer && decl.initializer.kind === ts.SyntaxKind.TrueKeyword) {
      valueExprId = conv.ast.data.expressions.length
      conv.ast.data.expressions.push({ literal: { kind: 4, value: addSrc(conv, "true") } })
    } else if (decl.initializer && decl.initializer.kind === ts.SyntaxKind.FalseKeyword) {
      valueExprId = conv.ast.data.expressions.length
      conv.ast.data.expressions.push({ literal: { kind: 4, value: addSrc(conv, "false") } })
    }

    let typeId: number | undefined
    if (decl.type) {
      typeId = mapType(conv, decl.type)
    } else if (decl.initializer && (ts.isNumericLiteral(decl.initializer) ||
      (ts.isPrefixUnaryExpression(decl.initializer) && ts.isNumericLiteral(decl.initializer.operand)))) {
      conv.ast.data.types.push({ primitive: { name: addName(conv, "cdouble") } })
      typeId = conv.ast.data.types.length - 1
    } else if (decl.initializer && ts.isStringLiteral(decl.initializer)) {
      conv.ast.data.types.push({ primitive: { name: addName(conv, "cstring") } })
      typeId = conv.ast.data.types.length - 1
    }
    let typeExprId: number | undefined
    if (typeId !== undefined) {
      typeExprId = conv.ast.data.expressions.length
      conv.ast.data.expressions.push({ type: { id: typeId } })
    }
    const bindingId = conv.ast.data.bindings.length
    if (valueExprId === undefined && decl.initializer === undefined) {
      const pragmaId = addImportjsPragma(conv, jsPattern(conv, decl.name.text))
      conv.ast.data.bindings.push({
        name: varName,
        dataType: typeExprId,
        runtime: true,
        mutable: true,
        pragmas: pragmaId,
      })
    } else {
      conv.ast.data.bindings.push({
        name: varName,
        dataType: typeExprId,
        value: valueExprId,
      })
    }

    const stmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ variable: { id: bindingId } })
    link_statement(conv, stmtId)
  }
}


function statement_interface_fields(conv: Converter, node: ts.InterfaceDeclaration): number | undefined {
  let firstField: number | undefined
  let prevField: number | undefined
  for (const member of node.members) {
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
  return firstField
}


function statement_interface_mergeExisting(conv: Converter, node: ts.InterfaceDeclaration, ifaceName: string, firstField: number | undefined): boolean {
  if (!conv.objectTypeIds.has(ifaceName)) return false
  const existingTypeId = conv.objectTypeIds.get(ifaceName)!
  const existingType = conv.ast.data.types[existingTypeId]
  if (existingType.object && firstField !== undefined) {
    if (existingType.object.fields === undefined) {
      existingType.object.fields = firstField
    } else {
      let lastField = existingType.object.fields
      while (conv.ast.data.bindings[lastField].next !== undefined) lastField = conv.ast.data.bindings[lastField].next!
      conv.ast.data.bindings[lastField].next = firstField
    }
  }
  for (const member of node.members) {
    if (!ts.isMethodSignature(member) || !member.name) continue
    const methodName = member.name.getText()
    const selfTypeId = conv.ast.data.types.length
    conv.ast.data.types.push({ primitive: { name: addName(conv, ifaceName) } })
    const classParamNames = new Set((node.typeParameters ?? []).map(tp => tp.name.text))
    const methodOnlyParams = ((ts.isMethodSignature(member) && member.typeParameters) ? [...member.typeParameters] : []).filter(tp => !classParamNames.has(tp.name.text))
    const mergedTypeParams: ts.TypeParameterDeclaration[] = [
      ...(node.typeParameters ?? []),
      ...methodOnlyParams,
    ]
    emitOrDedup(conv, prefixed(conv, methodName), member.parameters, member.type, "#." + methodName + "(@)", selfTypeId, mergedTypeParams.length > 0 ? mergedTypeParams : undefined, ifaceName + "." + methodName)
  }
  return true
}


function statement_interface_heritage_collect(conv: Converter, node: ts.InterfaceDeclaration): { start: number, end: number } | undefined {
  if (!node.heritageClauses) return undefined
  let linkRange: { start: number, end: number } | undefined
  for (const clause of node.heritageClauses) {
    if (clause.token !== ts.SyntaxKind.ExtendsKeyword) continue
    for (const baseType of clause.types) {
      const parentTypeId = mapType(conv, baseType as unknown as ts.TypeNode)
      const linkIdx = conv.ast.data.links.length
      conv.ast.data.links.push({ type: parentTypeId })
      if (!linkRange) linkRange = { start: linkIdx, end: linkIdx }
      else linkRange.end = linkIdx
    }
  }
  return linkRange
}


function statement_interface_field_getters(conv: Converter, node: ts.InterfaceDeclaration, ifaceName: string) {
  const selfTypeId = conv.ast.data.types.length
  conv.ast.data.types.push({ primitive: { name: addName(conv, ifaceName) } })
  if (node.typeParameters && node.typeParameters.length > 0) {
    let firstInstExpr: number | undefined
    let prevInstExpr: number | undefined
    for (const tp of node.typeParameters) {
      const paramTypeId = conv.ast.data.types.length
      conv.ast.data.types.push({ primitive: { name: addName(conv, tp.name.text) } })
      const exprId = conv.ast.data.expressions.length
      conv.ast.data.expressions.push({ type: { id: paramTypeId } })
      if (prevInstExpr !== undefined) conv.ast.data.expressions[prevInstExpr].type.next = exprId
      if (firstInstExpr === undefined) firstInstExpr = exprId
      prevInstExpr = exprId
    }
    conv.ast.data.types[selfTypeId].primitive.instantiation = firstInstExpr
  }
  for (const member of node.members) {
    if (!ts.isPropertySignature(member) || !member.name) continue
    const fieldName = sanitize(conv, unquote(member.name.getText()))
    const fieldTypeId = mapType(conv, member.type)
    const baseProcName = prefixed(conv, fieldName)
    let procName = conv.nimNames.has(nimNormalize(baseProcName))
      ? uniqueNimName(conv, ifaceName + "_" + fieldName)
      : baseProcName
    conv.nimNames.add(nimNormalize(procName))
    const funcName = addName(conv, procName)
    const selfTypeExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: selfTypeId } })
    const selfBinding = conv.ast.data.bindings.length
    conv.ast.data.bindings.push({ name: addName(conv, "self"), dataType: selfTypeExpr, private: true })
    const fieldRetExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: fieldTypeId } })
    let firstGeneric: number | undefined
    if (node.typeParameters && node.typeParameters.length > 0) {
      let prevGeneric: number | undefined
      for (const tp of node.typeParameters) {
        const genericId = conv.ast.data.bindings.length
        conv.ast.data.bindings.push({ name: addName(conv, tp.name.text), private: true })
        if (prevGeneric !== undefined) conv.ast.data.bindings[prevGeneric].next = genericId
        if (firstGeneric === undefined) firstGeneric = genericId
        prevGeneric = genericId
      }
    }
    const pragmaId = addImportjsPragma(conv, "#." + unquote(member.name.getText()))
    const procId = conv.ast.data.procedures.length
    conv.ast.data.procedures.push({
      name: funcName,
      arguments: selfBinding,
      returnType: fieldRetExpr,
      generics: firstGeneric,
      pragmas: pragmaId,
      impure: true,
    })
    const procStmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ procedure: { id: procId } })
    link_statement(conv, procStmtId)
  }
}


function statement_interface_methods(conv: Converter, node: ts.InterfaceDeclaration, ifaceName: string) {
  const selfTypeId = conv.ast.data.types.length
  conv.ast.data.types.push({ primitive: { name: addName(conv, ifaceName) } })
  if (node.typeParameters && node.typeParameters.length > 0) {
    let firstInstExpr: number | undefined
    let prevInstExpr: number | undefined
    for (const tp of node.typeParameters) {
      const paramTypeId = conv.ast.data.types.length
      conv.ast.data.types.push({ primitive: { name: addName(conv, tp.name.text) } })
      const exprId = conv.ast.data.expressions.length
      conv.ast.data.expressions.push({ type: { id: paramTypeId } })
      if (prevInstExpr !== undefined) conv.ast.data.expressions[prevInstExpr].type.next = exprId
      if (firstInstExpr === undefined) firstInstExpr = exprId
      prevInstExpr = exprId
    }
    conv.ast.data.types[selfTypeId].primitive.instantiation = firstInstExpr
  }
  for (const member of node.members) {
    if (!ts.isMethodSignature(member) || !member.name) continue
    const methodName = member.name.getText()
    const baseProcName = prefixed(conv, methodName)
    let procName = conv.nimNames.has(nimNormalize(baseProcName))
      ? uniqueNimName(conv, ifaceName + "_" + sanitize(conv, methodName))
      : baseProcName
    const classParamNames = new Set((node.typeParameters ?? []).map(tp => tp.name.text))
    const methodOnlyParams = ((ts.isMethodSignature(member) && member.typeParameters) ? [...member.typeParameters] : []).filter(tp => !classParamNames.has(tp.name.text))
    const mergedTypeParams: ts.TypeParameterDeclaration[] = [
      ...(node.typeParameters ?? []),
      ...methodOnlyParams,
    ]
    emitOrDedup(conv, procName, member.parameters, member.type, "#." + methodName + "(@)", selfTypeId, mergedTypeParams.length > 0 ? mergedTypeParams : undefined, ifaceName + "." + methodName)
  }
}


function statement_interface(conv: Converter, node: ts.InterfaceDeclaration, typeName: ReturnType<typeof addName>) {
  const ifaceName = prefixed(conv, node.name.text)
  const firstField = statement_interface_fields(conv, node)
  if (statement_interface_mergeExisting(conv, node, ifaceName, firstField)) return

  const linkRange = statement_interface_heritage_collect(conv, node)
  const hasMethods = node.members.some(m => ts.isMethodSignature(m))
  const isMultiInherit = linkRange !== undefined && linkRange.end > linkRange.start

  let typeId: number
  if (isMultiInherit || (firstField === undefined && linkRange === undefined && !hasMethods)) {
    conv.needsJsffi = true
    conv.ast.data.types.push({ primitive: { name: addName(conv, "JsObject"), keyword: addName(conv, "distinct") } })
    const distinctTargetId = conv.ast.data.types.length - 1
    typeId = conv.ast.data.types.length
    conv.ast.data.types.push({ alias: { name: typeName, target: addTypeExpr(conv, distinctTargetId) } })
  } else {
    let firstGeneric: number | undefined
    if (node.typeParameters && node.typeParameters.length > 0) {
      let prevGeneric: number | undefined
      for (const tp of node.typeParameters) {
        const genericName = addName(conv, tp.name.text)
        const genericId = conv.ast.data.bindings.length
        conv.ast.data.bindings.push({ name: genericName, private: true })
        if (prevGeneric !== undefined) conv.ast.data.bindings[prevGeneric].next = genericId
        if (firstGeneric === undefined) firstGeneric = genericId
        prevGeneric = genericId
      }
    }
    typeId = conv.ast.data.types.length
    conv.ast.data.types.push({ object: { name: typeName, fields: firstField, link: linkRange, pragmas: linkRange ? addInheritablePragma(conv) : undefined, generics: firstGeneric } })
  }
  conv.objectTypeIds.set(ifaceName, typeId)
  const stmtId = conv.ast.data.statements.length
  conv.ast.data.statements.push({ type: { id: typeId } })
  link_statement(conv, stmtId)

  if (isMultiInherit) statement_interface_field_getters(conv, node, ifaceName)
  statement_interface_methods(conv, node, ifaceName)
}


function statement_type_alias_union_string(conv: Converter, typeName: ReturnType<typeof addName>, aliasName: string, members: ts.NodeArray<ts.TypeNode>) {
  const cstringTypeId = conv.ast.data.types.length
  conv.ast.data.types.push({ primitive: { name: addName(conv, "cstring"), keyword: addName(conv, "distinct") } })
  const aliasId = conv.ast.data.types.length
  conv.ast.data.types.push({ alias: { name: typeName, target: addTypeExpr(conv, cstringTypeId) } })
  const typeStmtId = conv.ast.data.statements.length
  conv.ast.data.statements.push({ type: { id: aliasId } })
  link_statement(conv, typeStmtId)

  for (const member of members) {
    const literal = (member as ts.LiteralTypeNode).literal as ts.StringLiteral
    const literalIdent = literal.text.length === 0 ? "empty" : literal.text
    const constName = addName(conv, sanitize(conv, aliasName + "_" + literalIdent))
    const strLiteralId = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ literal: { kind: 2, value: addSrc(conv, literal.text) } })
    const argBindingId = conv.ast.data.bindings.length
    conv.ast.data.bindings.push({ value: strLiteralId, private: true })
    const castNameId = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ identifier: { name: addName(conv, aliasName) } })
    const callExprId = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ call: { name: castNameId, arguments: argBindingId } })
    const enumTypeId = conv.ast.data.types.length
    conv.ast.data.types.push({ primitive: { name: addName(conv, aliasName) } })
    const enumTypeExpr = conv.ast.data.expressions.length
    conv.ast.data.expressions.push({ type: { id: enumTypeId } })
    const bindingId = conv.ast.data.bindings.length
    conv.ast.data.bindings.push({ name: constName, dataType: enumTypeExpr, value: callExprId })
    const stmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ variable: { id: bindingId } })
    link_statement(conv, stmtId)
  }
}


function statement_type_alias_union_mixed(conv: Converter, typeName: ReturnType<typeof addName>) {
  conv.needsJsffi = true
  const jsObjectId = conv.ast.data.types.length
  conv.ast.data.types.push({ primitive: { name: addName(conv, "JsObject") } })
  const aliasId = conv.ast.data.types.length
  conv.ast.data.types.push({ alias: { name: typeName, target: addTypeExpr(conv, jsObjectId) } })
  const typeStmtId = conv.ast.data.statements.length
  conv.ast.data.statements.push({ type: { id: aliasId } })
  link_statement(conv, typeStmtId)
}


function statement_type_alias_direct(conv: Converter, node: ts.TypeAliasDeclaration, typeName: ReturnType<typeof addName>) {
  const targetId = mapType(conv, node.type)
  const targetType = conv.ast.data.types[targetId]

  if (node.typeParameters && node.typeParameters.length > 0 && targetType.procedure) {
    const proc = conv.ast.data.procedures[targetType.procedure.id]
    let prevGeneric: number | undefined
    for (const tp of node.typeParameters) {
      const genericName = addName(conv, tp.name.text)
      const genericId = conv.ast.data.bindings.length
      conv.ast.data.bindings.push({ name: genericName, private: true })
      if (prevGeneric !== undefined) conv.ast.data.bindings[prevGeneric].next = genericId
      if (proc.generics === undefined) proc.generics = genericId
      prevGeneric = genericId
    }
  }

  if (targetType.object && !targetType.object.keyword) {
    targetType.object.name = typeName
    const stmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ type: { id: targetId } })
    link_statement(conv, stmtId)
  } else if (targetType.procedure) {
    const proc = conv.ast.data.procedures[targetType.procedure.id]
    proc.name = typeName
    const stmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ type: { id: targetId } })
    link_statement(conv, stmtId)
  } else {
    const aliasId = conv.ast.data.types.length
    conv.ast.data.types.push({ alias: { name: typeName, target: addTypeExpr(conv, targetId) } })
    const stmtId = conv.ast.data.statements.length
    conv.ast.data.statements.push({ type: { id: aliasId } })
    link_statement(conv, stmtId)
  }
}


function statement_type_alias_union(conv: Converter, node: ts.TypeAliasDeclaration, typeName: ReturnType<typeof addName>) {
  const aliasName = prefixed(conv, node.name.text)
  const members = node.type.types
  const allStringLiterals = members.every(m =>
    ts.isLiteralTypeNode(m) && m.literal.kind === ts.SyntaxKind.StringLiteral
  )
  return (allStringLiterals)
    ? statement_type_alias_union_string(conv, typeName, aliasName, members)
    : statement_type_alias_union_mixed(conv, typeName)
}


function statement_type_alias(conv: Converter, node: ts.TypeAliasDeclaration, typeName: ReturnType<typeof addName>) {
  return (ts.isUnionTypeNode(node.type))
    ? statement_type_alias_union(conv, node, typeName)
    : statement_type_alias_direct(conv, node, typeName)
}


export function statement_type(conv: Converter, node: ts.Node) {
  if (!ts.isInterfaceDeclaration(node) && !ts.isTypeAliasDeclaration(node)) return
  const prefixedName = prefixed(conv, node.name.text)
  const typeName = addName(conv, prefixedName)
  conv.nimNames.add(nimNormalize(prefixedName))
  if (ts.isInterfaceDeclaration(node)) statement_interface(conv, node, typeName)
  if (ts.isTypeAliasDeclaration(node)) statement_type_alias(conv, node, typeName)
}


export function statement_namespace(conv: Converter, node: ts.Node) {
  if (!ts.isModuleDeclaration(node) || !node.name || !ts.isIdentifier(node.name) || !node.body) return
  conv.namespaceStack.push(node.name.text)
  if (ts.isModuleBlock(node.body)) {
    ts.forEachChild(node.body, n => ts_visitor(conv, n))
  }
  conv.namespaceStack.pop()
}


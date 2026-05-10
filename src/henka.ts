import ts from "typescript"
import type { astTF, Binding } from "@heysokam/astTF"

export function convert(ast: astTF, moduleId: number, sourceFile: ts.SourceFile, program: ts.Program) {

  let source = ""
  let needsJsffi = false
  let needsAsyncjs = false
  let needsOptions = false
  let needsUndefined = false
  let needsNull = false
  let syntheticCount = 0
  const objectTypeIds = new Map<string, number>()
  const emittedProcs = new Map<string, { procId: number, literalsId: number | null, literalParamIdx: number, hasSelf: boolean, paramCount: number }>()
  const procLiterals: number[][] = []
  const externalTypes = new Map<string, number>()
  const uniqueNames = new Map<string, number>()
  const namespaceStack: string[] = []

  function unquote(name: string): string {
    if ((name.startsWith('"') && name.endsWith('"')) || (name.startsWith("'") && name.endsWith("'")))
      return name.slice(1, -1)
    return name
  }

  function prefixed(name: string): string {
    const sanitized = sanitize(name)
    if (namespaceStack.length === 0) return sanitized
    return namespaceStack.join("_") + "_" + sanitized
  }

  function jsPattern(name: string): string {
    if (namespaceStack.length === 0) return name
    return namespaceStack.join(".") + "." + name
  }

  function addSrc(text: string) {
    const start = source.length
    source += text
    return { start, end: source.length }
  }

  function sanitize(name: string): string {
    if (name.length === 0) {
      const count = uniqueNames.get("unnamed") ?? 0
      uniqueNames.set("unnamed", count + 1)
      return "unnamed" + count
    }
    let result = name
    if (result.startsWith("__")) result = "internal" + result.slice(1)
    else if (result.startsWith("_")) result = "priv" + result
    if (/[^a-zA-Z0-9_]/.test(result)) result = "`" + result + "`"
    result = result.replace(/_{2,}/g, "_")
    if (result.endsWith("_")) {
      const count = uniqueNames.get(result) ?? 0
      uniqueNames.set(result, count + 1)
      result = result + count
    }
    return result
  }

  function addName(text: string) {
    return { location: addSrc(text) }
  }

  function addInheritablePragma(): number {
    if (!ast.data.expressions) ast.data.expressions = []
    if (!ast.data.pragmas) ast.data.pragmas = []
    const keyExpr = ast.data.expressions.length
    ast.data.expressions.push({ identifier: { name: addName("inheritable") } })
    const pragmaId = ast.data.pragmas.length
    ast.data.pragmas.push({ key: keyExpr })
    return pragmaId
  }

  let firstRootTypeStmt: number | undefined
  let lastRootTypeStmt: number | undefined
  let firstChildTypeStmt: number | undefined
  let lastChildTypeStmt: number | undefined
  let firstOtherStmt: number | undefined
  let lastOtherStmt: number | undefined

  function linkAfter(previousId: number, nextId: number) {
    const prev = ast.data.statements[previousId]
    if      (prev.procedure) prev.procedure.next = nextId
    else if (prev.variable)  prev.variable.next  = nextId
    else if (prev.type)      prev.type.next      = nextId
    else if (prev.import)    prev.import.next     = nextId
  }

  function linkRootTypeStmt(stmtId: number) {
    if (lastRootTypeStmt !== undefined) linkAfter(lastRootTypeStmt, stmtId)
    if (firstRootTypeStmt === undefined) firstRootTypeStmt = stmtId
    lastRootTypeStmt = stmtId
  }

  function linkChildTypeStmt(stmtId: number) {
    if (lastChildTypeStmt !== undefined) linkAfter(lastChildTypeStmt, stmtId)
    if (firstChildTypeStmt === undefined) firstChildTypeStmt = stmtId
    lastChildTypeStmt = stmtId
  }

  function linkOtherStmt(stmtId: number) {
    if (lastOtherStmt !== undefined) linkAfter(lastOtherStmt, stmtId)
    if (firstOtherStmt === undefined) firstOtherStmt = stmtId
    lastOtherStmt = stmtId
  }

  function linkStmt(stmtId: number) {
    const stmt = ast.data.statements[stmtId]
    if (stmt.type) {
      const typeData = ast.data.types[stmt.type.id]
      if (typeData.object?.link) linkChildTypeStmt(stmtId)
      else linkRootTypeStmt(stmtId)
    } else {
      linkOtherStmt(stmtId)
    }
  }

  function mapType(node: ts.TypeNode | undefined, checker: ts.TypeChecker): number {
    if (!ast.data.types) ast.data.types = []
    if (!ast.data.expressions) ast.data.expressions = []
    if (!ast.data.bindings) ast.data.bindings = []
    if (!ast.data.statements) ast.data.statements = []
    if (!ast.data.procedures) ast.data.procedures = []
    if (!node) {
      ast.data.types.push({ primitive: { name: addName("void") } })
      return ast.data.types.length - 1
    }

    const typeText = node.getText()

    switch (node.kind) {
      case ts.SyntaxKind.NumberKeyword:
        ast.data.types.push({ primitive: { name: addName("cdouble") } })
        break
      case ts.SyntaxKind.StringKeyword:
        ast.data.types.push({ primitive: { name: addName("cstring") } })
        break
      case ts.SyntaxKind.BooleanKeyword:
        ast.data.types.push({ primitive: { name: addName("bool") } })
        break
      case ts.SyntaxKind.VoidKeyword:
        ast.data.types.push({ primitive: { name: addName("void") } })
        break
      case ts.SyntaxKind.UndefinedKeyword:
        ast.data.types.push({ primitive: { name: addName("Undefined") } })
        needsUndefined = true
        break
      case ts.SyntaxKind.BigIntKeyword:
        ast.data.types.push({ primitive: { name: addName("BiggestInt") } })
        break
      case ts.SyntaxKind.AnyKeyword:
      case ts.SyntaxKind.ObjectKeyword:
      case ts.SyntaxKind.UnknownKeyword:
      case ts.SyntaxKind.TypeOperator:
        ast.data.types.push({ primitive: { name: addName("JsObject") } })
        needsJsffi = true
        break
      case ts.SyntaxKind.NeverKeyword:
        ast.data.types.push({ primitive: { name: addName("void") } })
        break
      case ts.SyntaxKind.TemplateLiteralType:
        ast.data.types.push({ primitive: { name: addName("cstring") } })
        break
      case ts.SyntaxKind.TypeReference: {
        const refNode = node as ts.TypeReferenceNode
        const refName = refNode.typeName.getText()
        if (refName === "Array" && refNode.typeArguments && refNode.typeArguments.length === 1) {
          const elemTypeId = mapType(refNode.typeArguments[0], checker)
          ast.data.types.push({ array: { name: addName("seq"), element: elemTypeId } })
        } else if (refName === "Promise" && refNode.typeArguments && refNode.typeArguments.length === 1) {
          const innerTypeId = mapType(refNode.typeArguments[0], checker)
          ast.data.types.push({ array: { name: addName("Future"), element: innerTypeId } })
          needsAsyncjs = true
        } else if (refNode.typeArguments && refNode.typeArguments.length > 0) {
          ast.data.types.push({ primitive: { name: addName("JsObject") } })
          needsJsffi = true
        } else {
          const symbol = checker.getSymbolAtLocation(refNode.typeName)
          const hasDeclarations = symbol?.declarations && symbol.declarations.length > 0
          const declFile = hasDeclarations ? symbol.declarations[0].getSourceFile().fileName : undefined
          const inputFiles = ast.data.modules.map(m => m.path)
          const isExternal = !symbol || !hasDeclarations || (declFile !== undefined && !inputFiles.includes(declFile))

          if (isExternal) {
            const existing = externalTypes.get(typeText)
            if (existing !== undefined) {
              ast.data.types.push({ primitive: { name: addName(sanitize(typeText)) } })
            } else {
              needsJsffi = true
              const jsObjectId = ast.data.types.length
              ast.data.types.push({ primitive: { name: addName("JsObject") } })
              const aliasId = ast.data.types.length
              ast.data.types.push({ alias: { name: addName(sanitize(typeText)), target: addTypeExpr(jsObjectId) } })
              const stmtId = ast.data.statements.length
              ast.data.statements.push({ type: { id: aliasId } })
              linkRootTypeStmt(stmtId)
              externalTypes.set(typeText, aliasId)
              ast.data.types.push({ primitive: { name: addName(sanitize(typeText)) } })
            }
            break
          }

          let resolvedName = typeText
          const isTypeParam = symbol.declarations?.some(d => ts.isTypeParameterDeclaration(d)) ?? false
          if (isTypeParam) {
            ast.data.types.push({ primitive: { name: addName(resolvedName) } })
            break
          }
          let fullName = checker.getFullyQualifiedName(symbol)
          const quoteEnd = fullName.lastIndexOf('"')
          if (quoteEnd >= 0) fullName = fullName.substring(quoteEnd + 2)
          if (fullName.includes(".")) {
            resolvedName = fullName.replace(/\./g, "_")
          }
          ast.data.types.push({ primitive: { name: addName(sanitize(resolvedName)) } })
        }
        break
      }
      case ts.SyntaxKind.ArrayType: {
        const elemTypeId = mapType((node as ts.ArrayTypeNode).elementType, checker)
        ast.data.types.push({ array: { name: addName("seq"), element: elemTypeId } })
        break
      }
      case ts.SyntaxKind.FunctionType: {
        const fnNode = node as ts.FunctionTypeNode
        const retTypeId = mapType(fnNode.type, checker)
        const retTypeExpr = ast.data.expressions.length
        ast.data.expressions.push({ type: { id: retTypeId } })

        let firstArg: number | undefined
        let prevArg: number | undefined
        for (const param of fnNode.parameters) {
          if (param.name.getText() === "this") continue
          const argName = addName(sanitize(param.name.getText()))
          const argTypeId = mapType(param.type, checker)
          const argTypeExpr = ast.data.expressions.length
          ast.data.expressions.push({ type: { id: argTypeId } })
          const bindingId = ast.data.bindings.length
          ast.data.bindings.push({ name: argName, dataType: argTypeExpr, private: true })
          if (prevArg !== undefined) ast.data.bindings[prevArg].next = bindingId
          if (firstArg === undefined) firstArg = bindingId
          prevArg = bindingId
        }

        const procId = ast.data.procedures.length
        ast.data.procedures.push({
          arguments: firstArg,
          returnType: retTypeExpr,
          impure: true,
          private: true,
        })
        ast.data.types.push({ procedure: { id: procId } })
        break
      }
      case ts.SyntaxKind.TypeLiteral: {
        const members = (node as ts.TypeLiteralNode).members
        let firstField: number | undefined
        let prevField: number | undefined
        for (const member of members) {
          if (ts.isPropertySignature(member) && member.name) {
            const fieldName = addName(sanitize(unquote(member.name.getText())))
            let fieldTypeId = mapType(member.type, checker)
            if (member.questionToken) {
              ast.data.types.push({ array: { name: addName("Option"), element: fieldTypeId } })
              fieldTypeId = ast.data.types.length - 1
              needsOptions = true
            }
            const fieldTypeExpr = ast.data.expressions.length
            ast.data.expressions.push({ type: { id: fieldTypeId } })
            const bindingId = ast.data.bindings.length
            ast.data.bindings.push({ name: fieldName, dataType: fieldTypeExpr })
            if (prevField !== undefined) ast.data.bindings[prevField].next = bindingId
            if (firstField === undefined) firstField = bindingId
            prevField = bindingId
          }
        }
        const syntheticName = "Anonymous" + syntheticCount++
        const objectTypeId = ast.data.types.length
        ast.data.types.push({ object: { name: addName(syntheticName), fields: firstField } })
        objectTypeIds.set(syntheticName, objectTypeId)
        const stmtId = ast.data.statements.length
        ast.data.statements.push({ type: { id: objectTypeId } })
        linkStmt(stmtId)
        ast.data.types.push({ primitive: { name: addName(syntheticName) } })
        break
      }
      case ts.SyntaxKind.UnionType: {
        const unionNode = node as ts.UnionTypeNode
        const nonUndefined = unionNode.types.filter(t =>
          t.kind !== ts.SyntaxKind.UndefinedKeyword &&
          !(ts.isLiteralTypeNode(t) && t.literal.kind === ts.SyntaxKind.NullKeyword)
        )
        if (nonUndefined.length === 1) {
          const innerTypeId = mapType(nonUndefined[0], checker)
          ast.data.types.push({ array: { name: addName("Option"), element: innerTypeId } })
          needsOptions = true
        } else {
          ast.data.types.push({ primitive: { name: addName("JsObject") } })
          needsJsffi = true
        }
        break
      }
      case ts.SyntaxKind.LiteralType: {
        const literal = (node as ts.LiteralTypeNode).literal
        if (literal.kind === ts.SyntaxKind.StringLiteral) {
          ast.data.types.push({ primitive: { name: addName("cstring") } })
        } else if (literal.kind === ts.SyntaxKind.NumericLiteral ||
                   (literal.kind === ts.SyntaxKind.PrefixUnaryExpression &&
                    ts.isNumericLiteral((literal as ts.PrefixUnaryExpression).operand))) {
          ast.data.types.push({ primitive: { name: addName("cdouble") } })
        } else if (literal.kind === ts.SyntaxKind.TrueKeyword ||
                   literal.kind === ts.SyntaxKind.FalseKeyword) {
          ast.data.types.push({ primitive: { name: addName("bool") } })
        } else if (literal.kind === ts.SyntaxKind.NullKeyword) {
          ast.data.types.push({ primitive: { name: addName("Null") } })
          needsNull = true
        } else {
          ast.data.types.push({ primitive: { name: addName(typeText) } })
        }
        break
      }
      case ts.SyntaxKind.IndexedAccessType:
        ast.data.types.push({ primitive: { name: addName("JsObject") } })
        needsJsffi = true
        break
      case ts.SyntaxKind.ParenthesizedType:
        return mapType((node as ts.ParenthesizedTypeNode).type, checker)
      case ts.SyntaxKind.IntersectionType:
        ast.data.types.push({ primitive: { name: addName("JsObject") } })
        needsJsffi = true
        break
      case ts.SyntaxKind.TupleType: {
        const tupleNode = node as ts.TupleTypeNode
        let firstField: number | undefined
        let prevField: number | undefined
        for (const elem of tupleNode.elements) {
          const isNamed = ts.isNamedTupleMember(elem)
          const typeNode = isNamed ? (elem as ts.NamedTupleMember).type : elem
          const elemTypeId = mapType(typeNode, checker)
          const elemTypeExpr = ast.data.expressions.length
          ast.data.expressions.push({ type: { id: elemTypeId } })
          const binding: Binding = { dataType: elemTypeExpr }
          if (isNamed) binding.name = addName((elem as ts.NamedTupleMember).name.getText())
          const bindingId = ast.data.bindings.length
          ast.data.bindings.push(binding)
          if (prevField !== undefined) ast.data.bindings[prevField].next = bindingId
          if (firstField === undefined) firstField = bindingId
          prevField = bindingId
        }
        ast.data.types.push({ object: { keyword: addName("tuple"), fields: firstField } })
        break
      }
      case ts.SyntaxKind.ExpressionWithTypeArguments: {
        const exprNode = node as ts.ExpressionWithTypeArguments
        const baseName = exprNode.expression.getText(node.getSourceFile())
        const typeId = ast.data.types.length
        ast.data.types.push({ primitive: { name: addName(sanitize(baseName)) } })
        if (exprNode.typeArguments && exprNode.typeArguments.length > 0) {
          let firstExpr: number | undefined
          let prevExpr: number | undefined
          for (const arg of exprNode.typeArguments) {
            const argTypeId = mapType(arg, checker)
            const exprId = ast.data.expressions.length
            ast.data.expressions.push({ type: { id: argTypeId } })
            if (prevExpr !== undefined) ast.data.expressions[prevExpr].type.next = exprId
            if (firstExpr === undefined) firstExpr = exprId
            prevExpr = exprId
          }
          ast.data.types[typeId].primitive.instantiation = firstExpr
        }
        return typeId
      }
      default:
        ast.data.types.push({ primitive: { name: addName(typeText) } })
    }
    return ast.data.types.length - 1
  }

  function addTypeExpr(typeId: number): number {
    if (!ast.data.expressions) ast.data.expressions = []
    const exprId = ast.data.expressions.length
    ast.data.expressions.push({ type: { id: typeId } })
    return exprId
  }

  function addImportjsPragma(pattern: string): number {
    if (!ast.data.expressions) ast.data.expressions = []
    if (!ast.data.pragmas) ast.data.pragmas = []
    const escaped = pattern.replace(/\$/g, "$$$$")
    const keyExpr = ast.data.expressions.length
    ast.data.expressions.push({ identifier: { name: addName("importjs") } })
    const valExpr = ast.data.expressions.length
    ast.data.expressions.push({ literal: { kind: 2, value: addSrc(escaped) } })
    const pragmaId = ast.data.pragmas.length
    ast.data.pragmas.push({ key: keyExpr, value: valExpr })
    return pragmaId
  }

  function pushLiteralExpr(literalNode: ts.Node): number {
    const exprId = ast.data.expressions.length
    if (ts.isStringLiteral(literalNode))
      ast.data.expressions.push({ literal: { kind: 2, value: addSrc(literalNode.text) } })
    else if (ts.isNumericLiteral(literalNode))
      ast.data.expressions.push({ literal: { kind: 1, value: addSrc(literalNode.text) } })
    else if (literalNode.kind === ts.SyntaxKind.TrueKeyword)
      ast.data.expressions.push({ literal: { kind: 4, value: addSrc("true") } })
    else if (literalNode.kind === ts.SyntaxKind.FalseKeyword)
      ast.data.expressions.push({ literal: { kind: 4, value: addSrc("false") } })
    else
      ast.data.expressions.push({ literal: { kind: 2, value: addSrc(literalNode.getText()) } })
    return exprId
  }

  function emitOrDedup(
    procName     : string,
    params       : ts.NodeArray<ts.ParameterDeclaration>,
    retTypeNode  : ts.TypeNode | undefined,
    pattern      : string,
    selfType?    : number,
    typeParams?  : ts.NodeArray<ts.TypeParameterDeclaration>,
    dedupKey?    : string,
  ): void {
    const mapKey = dedupKey ?? procName
    const existing = emittedProcs.get(mapKey)
    const literalParamIdx = params.findIndex(p => p.type && ts.isLiteralTypeNode(p.type))
    const literalParam = literalParamIdx >= 0 ? params[literalParamIdx] : undefined

    if (existing && literalParam && existing.literalsId !== null && existing.paramCount === params.length) {
      const literalNode = (literalParam.type as ts.LiteralTypeNode).literal
      procLiterals[existing.literalsId].push(pushLiteralExpr(literalNode))
    } else {
      addProc(procName, params, retTypeNode, pattern, selfType, typeParams)
      const procId = ast.data.procedures.length - 1
      let literalsId: number | null = null
      if (literalParam) {
        const literalNode = (literalParam.type as ts.LiteralTypeNode).literal
        literalsId = procLiterals.length
        procLiterals.push([pushLiteralExpr(literalNode)])
      }
      emittedProcs.set(mapKey, { procId, literalsId, literalParamIdx, hasSelf: selfType !== undefined, paramCount: params.length })
    }
  }

  function addProc(
    name        : string,
    params      : ts.NodeArray<ts.ParameterDeclaration>,
    retTypeNode : ts.TypeNode | undefined,
    pattern     : string,
    selfType?   : number,
    typeParams? : ts.NodeArray<ts.TypeParameterDeclaration>,
  ) {
    if (!ast.data.expressions) ast.data.expressions = []
    if (!ast.data.bindings) ast.data.bindings = []
    if (!ast.data.procedures) ast.data.procedures = []
    if (!ast.data.statements) ast.data.statements = []
    const funcName = addName(name)
    let retType: number | undefined
    if (retTypeNode) {
      const retTypeId = mapType(retTypeNode, checker)
      retType = ast.data.expressions.length
      ast.data.expressions.push({ type: { id: retTypeId } })
    }

    let firstArg: number | undefined
    let prevArg: number | undefined

    // Add self parameter for instance methods
    if (selfType !== undefined) {
      const selfName = addName("self")
      const selfTypeExpr = ast.data.expressions.length
      ast.data.expressions.push({ type: { id: selfType } })
      const bindingId = ast.data.bindings.length
      ast.data.bindings.push({ name: selfName, dataType: selfTypeExpr, private: true })
      firstArg = bindingId
      prevArg = bindingId
    }

    for (const param of params) {
      const argName = addName(sanitize(param.name.getText()))
      let argTypeId: number
      if (param.dotDotDotToken && param.type && ts.isArrayTypeNode(param.type)) {
        const elemTypeId = mapType(param.type.elementType, checker)
        ast.data.types.push({ array: { name: addName("varargs"), element: elemTypeId } })
        argTypeId = ast.data.types.length - 1
      } else {
        argTypeId = mapType(param.type, checker)
      }
      if (param.questionToken) {
        ast.data.types.push({ array: { name: addName("Option"), element: argTypeId } })
        argTypeId = ast.data.types.length - 1
        needsOptions = true
      }
      let defaultValueId: number | undefined
      if (param.initializer) {
        if (ts.isNumericLiteral(param.initializer)) {
          defaultValueId = ast.data.expressions.length
          ast.data.expressions.push({ literal: { kind: 1, value: addSrc(param.initializer.text) } })
        } else if (ts.isStringLiteral(param.initializer)) {
          defaultValueId = ast.data.expressions.length
          ast.data.expressions.push({ literal: { kind: 2, value: addSrc(param.initializer.text) } })
        } else if (param.initializer.kind === ts.SyntaxKind.TrueKeyword) {
          defaultValueId = ast.data.expressions.length
          ast.data.expressions.push({ literal: { kind: 4, value: addSrc("true") } })
        } else if (param.initializer.kind === ts.SyntaxKind.FalseKeyword) {
          defaultValueId = ast.data.expressions.length
          ast.data.expressions.push({ literal: { kind: 4, value: addSrc("false") } })
        }
      }
      const argTypeExpr = ast.data.expressions.length
      ast.data.expressions.push({ type: { id: argTypeId } })
      const bindingId = ast.data.bindings.length
      ast.data.bindings.push({ name: argName, dataType: argTypeExpr, private: true, value: defaultValueId })
      if (prevArg !== undefined) ast.data.bindings[prevArg].next = bindingId
      if (firstArg === undefined) firstArg = bindingId
      prevArg = bindingId
    }

    let pragmaId = addImportjsPragma(pattern)
    if (retTypeNode && retTypeNode.kind === ts.SyntaxKind.UndefinedKeyword) {
      const discardableKey = ast.data.expressions.length
      ast.data.expressions.push({ identifier: { name: addName("discardable") } })
      const discardableId = ast.data.pragmas.length
      ast.data.pragmas.push({ key: discardableKey, next: pragmaId })
      pragmaId = discardableId
    }
    let firstGeneric: number | undefined
    if (typeParams && typeParams.length > 0) {
      let prevGeneric: number | undefined
      for (const tp of typeParams) {
        const genericName = addName(tp.name.text)
        const genericId = ast.data.bindings.length
        ast.data.bindings.push({ name: genericName, private: true })
        if (prevGeneric !== undefined) ast.data.bindings[prevGeneric].next = genericId
        if (firstGeneric === undefined) firstGeneric = genericId
        prevGeneric = genericId
      }
    }

    const procId = ast.data.procedures.length
    ast.data.procedures.push({
      name: funcName,
      generics: firstGeneric,
      arguments: firstArg,
      returnType: retType,
      pragmas: pragmaId,
      impure: true,
    })

    const stmtId = ast.data.statements.length
    ast.data.statements.push({ procedure: { id: procId } })
    linkStmt(stmtId)
  }

  const checker = program.getTypeChecker()

  ts.forEachChild(sourceFile, function visit(node: ts.Node) {
    if (!ast.data.types) ast.data.types = []
    if (!ast.data.expressions) ast.data.expressions = []
    if (!ast.data.statements) ast.data.statements = []
    if (!ast.data.bindings) ast.data.bindings = []
    if (!ast.data.procedures) ast.data.procedures = []
    if (!ast.data.links) ast.data.links = []
    // Free function
    if (ts.isFunctionDeclaration(node) && node.name) {
      const symbol = checker.getSymbolAtLocation(node.name)
      const isOverloadImpl = node.body && symbol && (symbol.declarations?.length ?? 0) > 1
      if (!isOverloadImpl) {
        emitOrDedup(prefixed(node.name.text), node.parameters, node.type, jsPattern(node.name.text) + "(@)", undefined, node.typeParameters)
      }
    }

    // Class declaration — emit as `distinct JsObject`
    if (ts.isClassDeclaration(node) && node.name) {
      const className = node.name.text
      const prefixedClassName = prefixed(className)
      const jsClassName = jsPattern(className)

      needsJsffi = true
      ast.data.types.push({ primitive: { name: addName("JsObject"), keyword: addName("distinct") } })
      const distinctTargetId = ast.data.types.length - 1
      const aliasId = ast.data.types.length
      ast.data.types.push({ alias: { name: addName(prefixedClassName), target: addTypeExpr(distinctTargetId) } })
      const typeStmtId = ast.data.statements.length
      ast.data.statements.push({ type: { id: aliasId } })
      linkStmt(typeStmtId)

      // Emit fields as getter procs
      for (const member of node.members) {
        if (ts.isPropertyDeclaration(member) && member.name) {
          const fieldName = member.name.getText()
          const fieldTypeId = mapType(member.type, checker)
          const funcName = addName(prefixed(fieldName))
          const selfTypeId = ast.data.types.length
          ast.data.types.push({ primitive: { name: addName(prefixedClassName) } })
          const selfTypeExpr = ast.data.expressions.length
          ast.data.expressions.push({ type: { id: selfTypeId } })
          const selfBinding = ast.data.bindings.length
          ast.data.bindings.push({ name: addName("self"), dataType: selfTypeExpr, private: true })
          const fieldRetExpr = ast.data.expressions.length
          ast.data.expressions.push({ type: { id: fieldTypeId } })
          const procId = ast.data.procedures.length
          ast.data.procedures.push({
            name: funcName,
            arguments: selfBinding,
            returnType: fieldRetExpr,
            impure: true,
          })
          const pragmaId = addImportjsPragma("#." + fieldName)
          ast.data.procedures[procId].pragmas = pragmaId
          const stmtId = ast.data.statements.length
          ast.data.statements.push({ procedure: { id: procId } })
          linkStmt(stmtId)
        }
      }

      // Self type reference for methods
      const selfTypeId = ast.data.types.length
      ast.data.types.push({ primitive: { name: addName(prefixedClassName) } })

      // Constructor
      for (const member of node.members) {
        if (ts.isConstructorDeclaration(member)) {
          addProc("new" + prefixedClassName, member.parameters, undefined, "new " + jsClassName + "(@)")
          const lastProc = ast.data.procedures[ast.data.procedures.length - 1]
          const selfRetExpr = ast.data.expressions.length
          ast.data.expressions.push({ type: { id: selfTypeId } })
          lastProc.returnType = selfRetExpr
          break
        }
      }

      // Methods
      for (const member of node.members) {
        if (ts.isMethodDeclaration(member) && member.name) {
          const methodName = member.name.getText()
          const isStatic = member.modifiers?.some(m => m.kind === ts.SyntaxKind.StaticKeyword)

          if (isStatic) {
            addProc(prefixed(methodName), member.parameters, member.type, jsClassName + "." + methodName + "(@)")
          } else {
            addProc(prefixed(methodName), member.parameters, member.type, "#." + methodName + "(@)", selfTypeId)
          }
        }
      }
    }

    // Enum declaration
    if (ts.isEnumDeclaration(node)) {
      const enumName = prefixed(node.name.text)

      // Detect if string enum
      const isStringEnum = node.members.some(m =>
        m.initializer && ts.isStringLiteral(m.initializer)
      )

      // Emit type alias: EnumName = cint or cstring
      const baseTypeId = ast.data.types.length
      ast.data.types.push({ primitive: { name: addName(isStringEnum ? "cstring" : "cint") } })
      const aliasTypeId = ast.data.types.length
      ast.data.types.push({ alias: { name: addName(enumName), target: addTypeExpr(baseTypeId) } })
      const typeStmtId = ast.data.statements.length
      ast.data.statements.push({ type: { id: aliasTypeId } })
      linkStmt(typeStmtId)

      // Emit const for each member
      const enumTypeRefName = enumName
      for (const member of node.members) {
        if (!member.name) continue
        const memberName = member.name.getText()

        // Get the value
        let valueExprId: number | undefined
        const enumTypeId = ast.data.types.length
        ast.data.types.push({ primitive: { name: addName(enumTypeRefName) } })
        const enumTypeExpr = ast.data.expressions.length
        ast.data.expressions.push({ type: { id: enumTypeId } })

        if (member.initializer) {
          if (ts.isNumericLiteral(member.initializer)) {
            valueExprId = ast.data.expressions.length
            ast.data.expressions.push({ literal: { kind: 0, value: addSrc(member.initializer.text) } })
          } else if (ts.isStringLiteral(member.initializer)) {
            valueExprId = ast.data.expressions.length
            ast.data.expressions.push({ literal: { kind: 2, value: addSrc(member.initializer.text) } })
          }
        } else {
          // Auto-increment: use the member index
          const idx = node.members.indexOf(member)
          valueExprId = ast.data.expressions.length
          ast.data.expressions.push({ literal: { kind: 0, value: addSrc(String(idx)) } })
        }

        const bindingId = ast.data.bindings.length
        ast.data.bindings.push({
          name: addName(memberName),
          dataType: enumTypeExpr,
          value: valueExprId,
        })

        const stmtId = ast.data.statements.length
        ast.data.statements.push({ variable: { id: bindingId } })
        linkStmt(stmtId)
      }
    }

    if (ts.isVariableStatement(node)) {
      for (const decl of node.declarationList.declarations) {
        if (!ts.isIdentifier(decl.name)) continue
        const varName = addName(prefixed(decl.name.text))

        let valueExprId: number | undefined
        if (decl.initializer && ts.isNumericLiteral(decl.initializer)) {
          valueExprId = ast.data.expressions.length
          ast.data.expressions.push({
            literal: { kind: 1, value: addSrc(decl.initializer.text) },
          })
        } else if (decl.initializer && ts.isPrefixUnaryExpression(decl.initializer)
                   && ts.isNumericLiteral(decl.initializer.operand)) {
          valueExprId = ast.data.expressions.length
          ast.data.expressions.push({
            literal: { kind: 1, value: addSrc(decl.initializer.getText()) },
          })
        } else if (decl.initializer && ts.isStringLiteral(decl.initializer)) {
          valueExprId = ast.data.expressions.length
          ast.data.expressions.push({
            literal: { kind: 2, value: addSrc(decl.initializer.text) },
          })
        } else if (decl.initializer && decl.initializer.kind === ts.SyntaxKind.TrueKeyword) {
          valueExprId = ast.data.expressions.length
          ast.data.expressions.push({ literal: { kind: 4, value: addSrc("true") } })
        } else if (decl.initializer && decl.initializer.kind === ts.SyntaxKind.FalseKeyword) {
          valueExprId = ast.data.expressions.length
          ast.data.expressions.push({ literal: { kind: 4, value: addSrc("false") } })
        }

        let typeId: number | undefined
        if (decl.type) {
          typeId = mapType(decl.type, checker)
        } else if (decl.initializer && (ts.isNumericLiteral(decl.initializer) ||
                   (ts.isPrefixUnaryExpression(decl.initializer) && ts.isNumericLiteral(decl.initializer.operand)))) {
          ast.data.types.push({ primitive: { name: addName("cdouble") } })
          typeId = ast.data.types.length - 1
        } else if (decl.initializer && ts.isStringLiteral(decl.initializer)) {
          ast.data.types.push({ primitive: { name: addName("cstring") } })
          typeId = ast.data.types.length - 1
        }
        let typeExprId: number | undefined
        if (typeId !== undefined) {
          typeExprId = ast.data.expressions.length
          ast.data.expressions.push({ type: { id: typeId } })
        }
        const bindingId = ast.data.bindings.length
        if (valueExprId === undefined && decl.initializer === undefined) {
          const pragmaId = addImportjsPragma(jsPattern(decl.name.text))
          ast.data.bindings.push({
            name: varName,
            dataType: typeExprId,
            runtime: true,
            mutable: true,
            pragmas: pragmaId,
          })
        } else {
          ast.data.bindings.push({
            name: varName,
            dataType: typeExprId,
            value: valueExprId,
          })
        }

        const stmtId = ast.data.statements.length
        ast.data.statements.push({ variable: { id: bindingId } })
        linkStmt(stmtId)
      }
    }

    if (ts.isInterfaceDeclaration(node) || ts.isTypeAliasDeclaration(node)) {
      const typeName = addName(prefixed(node.name.text))

      if (ts.isInterfaceDeclaration(node)) {
        const ifaceName = prefixed(node.name.text)

        // Collect property fields
        let firstField: number | undefined
        let prevField: number | undefined
        for (const member of node.members) {
          if (ts.isPropertySignature(member) && member.name) {
            const fieldName = addName(sanitize(unquote(member.name.getText())))
            let fieldTypeId = mapType(member.type, checker)
            if (member.questionToken) {
              ast.data.types.push({ array: { name: addName("Option"), element: fieldTypeId } })
              fieldTypeId = ast.data.types.length - 1
              needsOptions = true
            }
            const fieldTypeExpr = ast.data.expressions.length
            ast.data.expressions.push({ type: { id: fieldTypeId } })
            const bindingId = ast.data.bindings.length
            ast.data.bindings.push({ name: fieldName, dataType: fieldTypeExpr })
            if (prevField !== undefined) ast.data.bindings[prevField].next = bindingId
            if (firstField === undefined) firstField = bindingId
            prevField = bindingId
          }
        }

        // Merge into existing interface declaration
        if (objectTypeIds.has(ifaceName)) {
          const existingTypeId = objectTypeIds.get(ifaceName)!
          const existingType = ast.data.types[existingTypeId]
          if (existingType.object && firstField !== undefined) {
            if (existingType.object.fields === undefined) {
              existingType.object.fields = firstField
            } else {
              let lastField = existingType.object.fields
              while (ast.data.bindings[lastField].next !== undefined) lastField = ast.data.bindings[lastField].next!
              ast.data.bindings[lastField].next = firstField
            }
          }
          // Emit methods from merged declaration
          for (const member of node.members) {
            if (!ts.isMethodSignature(member) || !member.name) continue
            const methodName = member.name.getText()
            const selfTypeId = ast.data.types.length
            ast.data.types.push({ primitive: { name: addName(ifaceName) } })
            emitOrDedup(prefixed(methodName), member.parameters, member.type, "#." + methodName + "(@)", selfTypeId, node.typeParameters, ifaceName + "." + methodName)
          }
          return
        }

        // Emit type
        let linkRange: { start: number, end: number } | undefined
        if (node.heritageClauses) {
          for (const clause of node.heritageClauses) {
            if (clause.token === ts.SyntaxKind.ExtendsKeyword) {
              for (const baseType of clause.types) {
                const parentTypeId = mapType(baseType as unknown as ts.TypeNode, checker)
                const linkIdx = ast.data.links.length
                ast.data.links.push({ type: parentTypeId })
                if (!linkRange) linkRange = { start: linkIdx, end: linkIdx }
                else linkRange.end = linkIdx
              }
            }
          }
        }
        let typeId: number
        const hasMethods = node.members.some(m => ts.isMethodSignature(m))
        const isMultiInherit = linkRange !== undefined && linkRange.end > linkRange.start
        if (isMultiInherit || (firstField === undefined && linkRange === undefined && !hasMethods)) {
          needsJsffi = true
          ast.data.types.push({ primitive: { name: addName("JsObject"), keyword: addName("distinct") } })
          const distinctTargetId = ast.data.types.length - 1
          typeId = ast.data.types.length
          ast.data.types.push({ alias: { name: typeName, target: addTypeExpr(distinctTargetId) } })
        } else {
          let firstGeneric: number | undefined
          if (node.typeParameters && node.typeParameters.length > 0) {
            let prevGeneric: number | undefined
            for (const tp of node.typeParameters) {
              const genericName = addName(tp.name.text)
              const genericId = ast.data.bindings.length
              ast.data.bindings.push({ name: genericName, private: true })
              if (prevGeneric !== undefined) ast.data.bindings[prevGeneric].next = genericId
              if (firstGeneric === undefined) firstGeneric = genericId
              prevGeneric = genericId
            }
          }
          typeId = ast.data.types.length
          ast.data.types.push({ object: { name: typeName, fields: firstField, link: linkRange, pragmas: linkRange ? addInheritablePragma() : undefined, generics: firstGeneric } })
        }
        objectTypeIds.set(ifaceName, typeId)
        const stmtId = ast.data.statements.length
        ast.data.statements.push({ type: { id: typeId } })
        linkStmt(stmtId)

        // Emit field getter procs for multi-inherit (distinct JsObject has no fields)
        if (isMultiInherit) {
          const selfTypeId = ast.data.types.length
          ast.data.types.push({ primitive: { name: addName(ifaceName) } })
          for (const member of node.members) {
            if (!ts.isPropertySignature(member) || !member.name) continue
            const fieldName = sanitize(unquote(member.name.getText()))
            const fieldTypeId = mapType(member.type, checker)
            const funcName = addName(prefixed(fieldName))
            const selfTypeExpr = ast.data.expressions.length
            ast.data.expressions.push({ type: { id: selfTypeId } })
            const selfBinding = ast.data.bindings.length
            ast.data.bindings.push({ name: addName("self"), dataType: selfTypeExpr, private: true })
            const fieldRetExpr = ast.data.expressions.length
            ast.data.expressions.push({ type: { id: fieldTypeId } })
            const pragmaId = addImportjsPragma("#." + unquote(member.name.getText()))
            const procId = ast.data.procedures.length
            ast.data.procedures.push({
              name: funcName,
              arguments: selfBinding,
              returnType: fieldRetExpr,
              pragmas: pragmaId,
              impure: true,
            })
            const procStmtId = ast.data.statements.length
            ast.data.statements.push({ procedure: { id: procId } })
            linkStmt(procStmtId)
          }
        }

        // Self type for method signatures
        const selfTypeId = ast.data.types.length
        ast.data.types.push({ primitive: { name: addName(ifaceName) } })
        if (node.typeParameters && node.typeParameters.length > 0) {
          let firstInstExpr: number | undefined
          let prevInstExpr: number | undefined
          for (const tp of node.typeParameters) {
            const paramTypeId = ast.data.types.length
            ast.data.types.push({ primitive: { name: addName(tp.name.text) } })
            const exprId = ast.data.expressions.length
            ast.data.expressions.push({ type: { id: paramTypeId } })
            if (prevInstExpr !== undefined) ast.data.expressions[prevInstExpr].type.next = exprId
            if (firstInstExpr === undefined) firstInstExpr = exprId
            prevInstExpr = exprId
          }
          ast.data.types[selfTypeId].primitive.instantiation = firstInstExpr
        }

        // Emit method signatures as procs
        for (const member of node.members) {
          if (!ts.isMethodSignature(member) || !member.name) continue
          const methodName = member.name.getText()
          emitOrDedup(prefixed(methodName), member.parameters, member.type, "#." + methodName + "(@)", selfTypeId, node.typeParameters, ifaceName + "." + methodName)
        }
      }

      if (ts.isTypeAliasDeclaration(node)) {
        const aliasName = prefixed(node.name.text)

        // String literal union → distinct cstring + consts
        if (ts.isUnionTypeNode(node.type)) {
          const members = node.type.types
          const allStringLiterals = members.every(m =>
            ts.isLiteralTypeNode(m) && m.literal.kind === ts.SyntaxKind.StringLiteral
          )
          if (allStringLiterals) {
            const cstringTypeId = ast.data.types.length
            ast.data.types.push({ primitive: { name: addName("cstring"), keyword: addName("distinct") } })
            const aliasId = ast.data.types.length
            ast.data.types.push({ alias: { name: typeName, target: addTypeExpr(cstringTypeId) } })
            const typeStmtId = ast.data.statements.length
            ast.data.statements.push({ type: { id: aliasId } })
            linkStmt(typeStmtId)

            for (const member of members) {
              const literal = (member as ts.LiteralTypeNode).literal as ts.StringLiteral
              const literalIdent = literal.text.length === 0 ? "empty" : literal.text
              const constName = addName(sanitize(aliasName + "_" + literalIdent))
              const strLiteralId = ast.data.expressions.length
              ast.data.expressions.push({ literal: { kind: 2, value: addSrc(literal.text) } })
              const argBindingId = ast.data.bindings.length
              ast.data.bindings.push({ value: strLiteralId, private: true })
              const castNameId = ast.data.expressions.length
              ast.data.expressions.push({ identifier: { name: addName(aliasName) } })
              const callExprId = ast.data.expressions.length
              ast.data.expressions.push({ call: { name: castNameId, arguments: argBindingId } })
              const enumTypeId = ast.data.types.length
              ast.data.types.push({ primitive: { name: addName(aliasName) } })
              const enumTypeExpr = ast.data.expressions.length
              ast.data.expressions.push({ type: { id: enumTypeId } })
              const bindingId = ast.data.bindings.length
              ast.data.bindings.push({ name: constName, dataType: enumTypeExpr, value: callExprId })
              const stmtId = ast.data.statements.length
              ast.data.statements.push({ variable: { id: bindingId } })
              linkStmt(stmtId)
            }
          } else {
            needsJsffi = true
            const jsObjectId = ast.data.types.length
            ast.data.types.push({ primitive: { name: addName("JsObject") } })
            const aliasId = ast.data.types.length
            ast.data.types.push({ alias: { name: typeName, target: addTypeExpr(jsObjectId) } })
            const typeStmtId = ast.data.statements.length
            ast.data.statements.push({ type: { id: aliasId } })
            linkStmt(typeStmtId)
          }
        } else {
          const targetId = mapType(node.type, checker)
          const targetType = ast.data.types[targetId]

          if (targetType.object && !targetType.object.keyword) {
            targetType.object.name = typeName
            const stmtId = ast.data.statements.length
            ast.data.statements.push({ type: { id: targetId } })
            linkStmt(stmtId)
          } else {
            const aliasId = ast.data.types.length
            ast.data.types.push({ alias: { name: typeName, target: addTypeExpr(targetId) } })
            const stmtId = ast.data.statements.length
            ast.data.statements.push({ type: { id: aliasId } })
            linkStmt(stmtId)
          }
        }
      }
    }

    // Namespace declaration
    if (ts.isModuleDeclaration(node) && node.name && ts.isIdentifier(node.name) && node.body) {
      namespaceStack.push(node.name.text)
      if (ts.isModuleBlock(node.body)) {
        ts.forEachChild(node.body, visit)
      }
      namespaceStack.pop()
    }
  })

  // Retroactively patch parent types as inheritable
  for (const typeEntry of ast.data.types) {
    if (typeEntry.object && typeEntry.object.link) {
      const linkRange = typeEntry.object.link
      for (let linkIdx = linkRange.start; linkIdx <= linkRange.end; linkIdx++) {
        const parentTypeId = ast.data.links[linkIdx].type
        const parentType = ast.data.types[parentTypeId]
        if (parentType.primitive) {
          const parentName = source.substring(parentType.primitive.name.location.start, parentType.primitive.name.location.end)
          const parentObjectId = objectTypeIds.get(parentName)
          if (parentObjectId !== undefined) {
            const parentObj = ast.data.types[parentObjectId]
            if (parentObj.object && !parentObj.object.pragmas) {
              parentObj.object.pragmas = addInheritablePragma()
            }
          }
        }
      }
    }
  }

  // Resolve overload dedup: emit synthetic distinct types + consts for collapsed overloads
  for (const [procName, { procId, literalsId, literalParamIdx, hasSelf }] of emittedProcs) {
    if (literalsId === null) continue
    const literals = procLiterals[literalsId]
    if (literals.length <= 1) continue

    const proc = ast.data.procedures[procId]
    if (proc.arguments === undefined) continue

    // Walk binding chain to the literal param position (skip self if present)
    let paramBindingId: number = proc.arguments
    const skipCount = literalParamIdx + (hasSelf ? 1 : 0)
    for (let idx = 0; idx < skipCount; idx++) {
      const next = ast.data.bindings[paramBindingId].next
      if (next === undefined) break
      paramBindingId = next
    }
    const paramBinding = ast.data.bindings[paramBindingId]
    const paramNameLoc = paramBinding.name?.location
    const paramName = paramNameLoc ? source.substring(paramNameLoc.start, paramNameLoc.end) : "param"

    // Determine base type from first literal's kind
    const firstLiteral = ast.data.expressions[literals[0]]
    const literalKind = firstLiteral.literal.kind
    const baseTypeName = literalKind === 2 ? "cstring" : literalKind === 1 ? "cdouble" : "bool"

    // Create synthetic type name: ProcName_paramName (use map key for uniqueness)
    const baseName = procName.replace(".", "_")
    const syntheticName = baseName.charAt(0).toUpperCase() + baseName.slice(1) + "_" + paramName

    // Emit: type SyntheticName* = distinct BaseType
    const baseTypeId = ast.data.types.length
    ast.data.types.push({ primitive: { name: addName(baseTypeName), keyword: addName("distinct") } })
    const aliasTypeId = ast.data.types.length
    ast.data.types.push({ alias: { name: addName(syntheticName), target: addTypeExpr(baseTypeId) } })
    const typeStmtId = ast.data.statements.length
    ast.data.statements.push({ type: { id: aliasTypeId } })
    linkRootTypeStmt(typeStmtId)

    // Modify the proc's param binding to use the synthetic type
    const syntheticRefTypeId = ast.data.types.length
    ast.data.types.push({ primitive: { name: addName(syntheticName) } })
    const syntheticTypeExpr = ast.data.expressions.length
    ast.data.expressions.push({ type: { id: syntheticRefTypeId } })
    paramBinding.dataType = syntheticTypeExpr

    // Change proc return type to JsObject (different overloads had different returns)
    needsJsffi = true
    const jsObjectTypeId = ast.data.types.length
    ast.data.types.push({ primitive: { name: addName("JsObject") } })
    const jsObjectExpr = ast.data.expressions.length
    ast.data.expressions.push({ type: { id: jsObjectTypeId } })
    ast.data.procedures[procId].returnType = jsObjectExpr

    // Emit consts for each literal value
    for (const literalExprId of literals) {
      const litExpr = ast.data.expressions[literalExprId]
      const litLoc = litExpr.literal.value
      const litText = source.substring(litLoc.start, litLoc.end)
      const constName = addName(sanitize(syntheticName + "_" + litText))
      const argBindingId = ast.data.bindings.length
      ast.data.bindings.push({ value: literalExprId, private: true })
      const castNameExpr = ast.data.expressions.length
      ast.data.expressions.push({ identifier: { name: addName(syntheticName) } })
      const callExprId = ast.data.expressions.length
      ast.data.expressions.push({ call: { name: castNameExpr, arguments: argBindingId } })
      const constTypeId = ast.data.types.length
      ast.data.types.push({ primitive: { name: addName(syntheticName) } })
      const constTypeExpr = ast.data.expressions.length
      ast.data.expressions.push({ type: { id: constTypeId } })
      const constBindingId = ast.data.bindings.length
      ast.data.bindings.push({ name: constName, dataType: constTypeExpr, value: callExprId })
      const constStmtId = ast.data.statements.length
      ast.data.statements.push({ variable: { id: constBindingId } })
      linkStmt(constStmtId)
    }
  }

  // Topological sort of child type chain so parents come before children
  if (firstChildTypeStmt !== undefined) {
    const children: number[] = []
    let walk: number | undefined = firstChildTypeStmt
    while (walk !== undefined) {
      children.push(walk)
      walk = ast.data.statements[walk].type?.next
    }

    const nameToIdx = new Map<string, number>()
    for (let idx = 0; idx < children.length; idx++) {
      const typeData = ast.data.types[ast.data.statements[children[idx]].type!.id]
      const loc = typeData.object?.name?.location ?? typeData.alias?.name?.location
      if (loc) nameToIdx.set(source.slice(loc.start, loc.end), idx)
    }

    const sorted: number[] = []
    const visited = new Set<number>()
    function visit(idx: number) {
      if (visited.has(idx)) return
      visited.add(idx)
      const typeData = ast.data.types[ast.data.statements[children[idx]].type!.id]
      if (typeData.object?.link && ast.data.links) {
        for (let linkIdx = typeData.object.link.start; linkIdx <= typeData.object.link.end; linkIdx++) {
          const parentType = ast.data.types[ast.data.links[linkIdx].type]
          const parentLoc = parentType.object?.name?.location ?? parentType.primitive?.name?.location
          if (parentLoc) {
            const parentIdx = nameToIdx.get(source.slice(parentLoc.start, parentLoc.end))
            if (parentIdx !== undefined) visit(parentIdx)
          }
        }
      }
      sorted.push(children[idx])
    }
    for (let idx = 0; idx < children.length; idx++) visit(idx)

    for (let idx = 0; idx < sorted.length - 1; idx++) ast.data.statements[sorted[idx]].type!.next = sorted[idx + 1]
    delete ast.data.statements[sorted[sorted.length - 1]].type!.next
    firstChildTypeStmt = sorted[0]
    lastChildTypeStmt = sorted[sorted.length - 1]
  }

  // Stitch chains: root types → child types → others
  if (lastRootTypeStmt !== undefined && firstChildTypeStmt !== undefined) {
    linkAfter(lastRootTypeStmt, firstChildTypeStmt)
  }
  const lastTypeStmt = lastChildTypeStmt ?? lastRootTypeStmt
  if (lastTypeStmt !== undefined && firstOtherStmt !== undefined) {
    linkAfter(lastTypeStmt, firstOtherStmt)
  }
  const firstTypeStmt = firstRootTypeStmt ?? firstChildTypeStmt
  ast.data.modules[moduleId].body = firstTypeStmt ?? firstOtherStmt

  if (needsNull) {
    const passthroughLoc = addSrc("type Null* = distinct JsObject\n")
    const stmtId = ast.data.statements.length
    ast.data.statements.push({ passthrough: { location: passthroughLoc, next: ast.data.modules[moduleId].body } })
    ast.data.modules[moduleId].body = stmtId
    needsJsffi = true
  }

  if (needsUndefined) {
    const passthroughLoc = addSrc("type Undefined* = distinct pointer\n")
    const stmtId = ast.data.statements.length
    ast.data.statements.push({ passthrough: { location: passthroughLoc, next: ast.data.modules[moduleId].body } })
    ast.data.modules[moduleId].body = stmtId
  }

  if (needsOptions) {
    const keyword = addName("import")
    const path = addSrc("std/options")
    const importStmtId = ast.data.statements.length
    ast.data.statements.push({ import: { keyword, path, next: ast.data.modules[moduleId].body } })
    ast.data.modules[moduleId].body = importStmtId
  }

  if (needsAsyncjs) {
    const keyword = addName("import")
    const path = addSrc("std/asyncjs")
    const importStmtId = ast.data.statements.length
    ast.data.statements.push({ import: { keyword, path, next: ast.data.modules[moduleId].body } })
    ast.data.modules[moduleId].body = importStmtId
  }

  if (needsJsffi) {
    const keyword = addName("import")
    const path = addSrc("std/jsffi")
    const importStmtId = ast.data.statements.length
    ast.data.statements.push({ import: { keyword, path, next: ast.data.modules[moduleId].body } })
    ast.data.modules[moduleId].body = importStmtId
  }

  ast.data.modules[moduleId].source = source
}

//______________________________________
// @section Entry Point
//____________________________
if (import.meta.main) run()
function run () :void {
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


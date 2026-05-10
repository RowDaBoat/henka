import ts from "typescript"
import type { astTF } from "@heysokam/astTF"

export function convert(ast: astTF, moduleId: number, sourceFile: ts.SourceFile, program: ts.Program) {

  let source = ""
  let needsJsffi = false
  let needsAsyncjs = false
  let needsOptions = false
  let needsUndefined = false
  let syntheticCount = 0
  const objectTypeIds = new Map<string, number>()
  const namespaceStack: string[] = []

  function unquote(name: string): string {
    if ((name.startsWith('"') && name.endsWith('"')) || (name.startsWith("'") && name.endsWith("'")))
      return name.slice(1, -1)
    return name
  }

  function prefixed(name: string): string {
    if (namespaceStack.length === 0) return name
    return namespaceStack.join("_") + "_" + name
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

  let firstTypeStmt: number | undefined
  let lastTypeStmt: number | undefined
  let firstOtherStmt: number | undefined
  let lastOtherStmt: number | undefined

  function linkAfter(previousId: number, nextId: number) {
    const prev = ast.data.statements[previousId]
    if      (prev.procedure) prev.procedure.next = nextId
    else if (prev.variable)  prev.variable.next  = nextId
    else if (prev.type)      prev.type.next      = nextId
    else if (prev.import)    prev.import.next     = nextId
  }

  function linkTypeStmt(stmtId: number) {
    if (lastTypeStmt !== undefined) linkAfter(lastTypeStmt, stmtId)
    if (firstTypeStmt === undefined) firstTypeStmt = stmtId
    lastTypeStmt = stmtId
  }

  function linkOtherStmt(stmtId: number) {
    if (lastOtherStmt !== undefined) linkAfter(lastOtherStmt, stmtId)
    if (firstOtherStmt === undefined) firstOtherStmt = stmtId
    lastOtherStmt = stmtId
  }

  function linkStmt(stmtId: number) {
    const stmt = ast.data.statements[stmtId]
    if (stmt.type) linkTypeStmt(stmtId)
    else linkOtherStmt(stmtId)
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
      case ts.SyntaxKind.AnyKeyword:
        ast.data.types.push({ primitive: { name: addName("JsObject") } })
        needsJsffi = true
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
          let resolvedName = typeText
          if (symbol) {
            let fullName = checker.getFullyQualifiedName(symbol)
            const quoteEnd = fullName.lastIndexOf('"')
            if (quoteEnd >= 0) fullName = fullName.substring(quoteEnd + 2)
            if (fullName.includes(".")) {
              resolvedName = fullName.replace(/\./g, "_")
            }
          }
          ast.data.types.push({ primitive: { name: addName(resolvedName) } })
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
          const argName = addName(param.name.getText())
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
            const fieldName = addName(unquote(member.name.getText()))
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
        } else {
          ast.data.types.push({ primitive: { name: addName(typeText) } })
        }
        break
      }
      default:
        ast.data.types.push({ primitive: { name: addName(typeText) } })
    }
    return ast.data.types.length - 1
  }

  function addImportjsPragma(pattern: string): number {
    if (!ast.data.expressions) ast.data.expressions = []
    if (!ast.data.pragmas) ast.data.pragmas = []
    const keyExpr = ast.data.expressions.length
    ast.data.expressions.push({ identifier: { name: addName("importjs") } })
    const valExpr = ast.data.expressions.length
    ast.data.expressions.push({ literal: { kind: 2, value: addSrc(pattern) } })
    const pragmaId = ast.data.pragmas.length
    ast.data.pragmas.push({ key: keyExpr, value: valExpr })
    return pragmaId
  }

  function addProc(name: string, params: ts.NodeArray<ts.ParameterDeclaration>, retTypeNode: ts.TypeNode | undefined, pattern: string, selfType?: number) {
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
      const argName = addName(param.name.getText())
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
    const procId = ast.data.procedures.length
    ast.data.procedures.push({
      name: funcName,
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
        addProc(prefixed(node.name.text), node.parameters, node.type, jsPattern(node.name.text) + "(@)")
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
      ast.data.types.push({ alias: { name: addName(prefixedClassName), target: distinctTargetId } })
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
      ast.data.types.push({ alias: { name: addName(enumName), target: baseTypeId } })
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
        ast.data.bindings.push({
          name: varName,
          dataType: typeExprId,
          value: valueExprId,
        })

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
            const fieldName = addName(unquote(member.name.getText()))
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
        if (firstField === undefined && linkRange === undefined && !hasMethods) {
          needsJsffi = true
          ast.data.types.push({ primitive: { name: addName("JsObject"), keyword: addName("distinct") } })
          const distinctTargetId = ast.data.types.length - 1
          typeId = ast.data.types.length
          ast.data.types.push({ alias: { name: typeName, target: distinctTargetId } })
        } else {
          typeId = ast.data.types.length
          ast.data.types.push({ object: { name: typeName, fields: firstField, link: linkRange, pragmas: linkRange ? addInheritablePragma() : undefined } })
        }
        objectTypeIds.set(ifaceName, typeId)
        const stmtId = ast.data.statements.length
        ast.data.statements.push({ type: { id: typeId } })
        linkStmt(stmtId)

        // Self type for method signatures
        const selfTypeId = ast.data.types.length
        ast.data.types.push({ primitive: { name: addName(ifaceName) } })

        // Emit method signatures as procs
        for (const member of node.members) {
          if (ts.isMethodSignature(member) && member.name) {
            const methodName = member.name.getText()
            addProc(prefixed(methodName), member.parameters, member.type, "#." + methodName + "(@)", selfTypeId)
          }
        }
      }

      if (ts.isTypeAliasDeclaration(node)) {
        const targetId = mapType(node.type, checker)
        const targetType = ast.data.types[targetId]

        if (targetType.object) {
          targetType.object.name = typeName
          const stmtId = ast.data.statements.length
          ast.data.statements.push({ type: { id: targetId } })
          linkStmt(stmtId)
        } else {
          const aliasId = ast.data.types.length
          ast.data.types.push({ alias: { name: typeName, target: targetId } })
          const stmtId = ast.data.statements.length
          ast.data.statements.push({ type: { id: aliasId } })
          linkStmt(stmtId)
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

  // Stitch chains: types first, then others
  if (lastTypeStmt !== undefined && firstOtherStmt !== undefined) {
    linkAfter(lastTypeStmt, firstOtherStmt)
  }
  ast.data.modules[moduleId].body = firstTypeStmt ?? firstOtherStmt

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


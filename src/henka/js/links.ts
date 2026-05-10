import type { Converter } from "./converter"

export function link_after(conv: Converter, previousId: number, nextId: number) {
  const prev = conv.ast.data.statements[previousId]
  if (prev.procedure) prev.procedure.next = nextId
  else if (prev.variable) prev.variable.next = nextId
  else if (prev.type) prev.type.next = nextId
  else if (prev.import) prev.import.next = nextId
}


export function link_statement_type_root(conv: Converter, stmtId: number) {
  if (conv.lastRootTypeStmt !== undefined) link_after(conv, conv.lastRootTypeStmt, stmtId)
  if (conv.firstRootTypeStmt === undefined) conv.firstRootTypeStmt = stmtId
  conv.lastRootTypeStmt = stmtId
}


function link_statement_type_child(conv: Converter, stmtId: number) {
  if (conv.lastChildTypeStmt !== undefined) link_after(conv, conv.lastChildTypeStmt, stmtId)
  if (conv.firstChildTypeStmt === undefined) conv.firstChildTypeStmt = stmtId
  conv.lastChildTypeStmt = stmtId
}


function link_statement_other(conv: Converter, stmtId: number) {
  if (conv.lastOtherStmt !== undefined) link_after(conv, conv.lastOtherStmt, stmtId)
  if (conv.firstOtherStmt === undefined) conv.firstOtherStmt = stmtId
  conv.lastOtherStmt = stmtId
}


export function link_statement(conv: Converter, stmtId: number) {
  const stmt = conv.ast.data.statements[stmtId]
  if (stmt.type) {
    const typeData = conv.ast.data.types[stmt.type.id]
    if (typeData.object?.link) link_statement_type_child(conv, stmtId)
    else link_statement_type_root(conv, stmtId)
  } else {
    link_statement_other(conv, stmtId)
  }
}


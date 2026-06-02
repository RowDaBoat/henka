export function getMap(): Map<string, number> { return new Map() }
export function getSet(): Set<string> { return new Set() }
export function toRecord(map: Map<string, number>): Record<string, number> { return {} }

export interface Cache {
  entries: Map<string, string>
  keys: Set<string>
  get(key: string): string | undefined
  set(key: string, value: string): void
}

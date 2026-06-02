export interface Collection<T> {
  length: number
  get(index: number): T
  add(item: T): void
}

export interface Pair<K, V> {
  key: K
  value: V
}

export interface StringList extends Collection<string> {
  join(separator: string): string
}

export interface NumberPair extends Pair<string, number> {
  label: string
}

export function createList(): Collection<string> { return {} as any }
export function createPair(): Pair<string, number> { return {} as any }

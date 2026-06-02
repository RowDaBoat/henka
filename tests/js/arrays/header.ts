export function sum(items: number[]): number { return 0 }
export function join(items: string[]): string { return "" }
export function concat(a: Array<number>, b: Array<number>): Array<number> { return [] }
export function filter(items: Array<string>, pred: (item: string) => boolean): Array<string> { return [] }

export interface List {
  items: Array<number>
  names: string[]
  get(index: number): string
  append(item: number): void
}

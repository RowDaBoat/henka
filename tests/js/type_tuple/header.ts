export function pair(): [number, string] { return [0, ""] }
export function triple(): [number, string, boolean] { return [0, "", false] }
export function named(): [count: number, label: string] { return [0, ""] }

export type Pair = [number, string]
export type NamedPair = [first: number, second: string]

export interface Stream {
  tee(): [number, string]
  split(): [head: string, tail: string]
}

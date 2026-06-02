export type Callback = (x: number) => void
export type Predicate = (item: string) => boolean
export type Transform = (input: number, scale: number) => number

export function forEach(items: number[], cb: (item: number) => void): void {}
export function map(items: number[], fn: (item: number) => number): number[] { return [] }

export interface EventEmitter {
  on(event: string, handler: (data: string) => void): void
  off(event: string, handler: (data: string) => void): void
}

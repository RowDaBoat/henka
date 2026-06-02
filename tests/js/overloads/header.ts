export function parse(input: string): number
export function parse(input: number): string
export function parse(input: string | number): string | number { return 0 }

export function stringify(value: number): string
export function stringify(value: boolean): string
export function stringify(value: number | boolean): string { return "" }

export interface Emitter {
  emit(event: "click", x: number, y: number): void
  emit(event: "key", code: string): void
  emit(event: string, ...args: any[]): void
}

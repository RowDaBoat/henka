export function parse(input: string): any {}
export function stringify(value: any): string {}
export function clone(obj: any, deep: boolean): any {}

export interface DynamicStore {
  data: any
  get(key: string): any
  set(key: string, value: any): void
}

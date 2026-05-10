export interface Person {
  name: string
  age: number
}

export function getKey(key: keyof Person): string { return "" }
export function getValue(obj: Person, key: keyof Person): string | number { return "" }

export function add(a: number, b: number): number {
  return a + b
}

export function greet(name: string): string {
  return "Hello, " + name
}

export const PI = 3.14159

export interface Vec2 {
  x: number
  y: number
}

export function magnitude(v: Vec2): number {
  return Math.sqrt(v.x * v.x + v.y * v.y)
}

export type Color = {
  r: number
  g: number
  b: number
  a: number
}

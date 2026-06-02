export namespace Math {
  export function add(a: number, b: number): number { return 0 }
  export function sub(a: number, b: number): number { return 0 }
  export const PI: number = 3.14

  export interface Vec2 {
    x: number
    y: number
  }

  export function magnitude(v: Vec2): number { return 0 }
}

export namespace App {
  export namespace Config {
    export interface Options {
      debug: boolean
      verbose: boolean
    }
    export function load(path: string): Options { return { debug: false, verbose: false } }
  }

  export function start(): void {}
}

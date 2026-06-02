export interface ExtA { valueA: number }
export interface ExtB { valueB: string }
export interface ExtC { valueC: boolean }

// Case 1: All overloads have same return type
export function getConfig(name: "host"): string
export function getConfig(name: "port"): string
export function getConfig(name: "mode"): string
export function getConfig(name: string): string { return "" }

// Case 2: Overloads have different return types
export function getExtension(name: "EXT_A"): ExtA
export function getExtension(name: "EXT_B"): ExtB
export function getExtension(name: "EXT_C"): ExtC
export function getExtension(name: string): any { return {} }

// Case 3: Multiple params, only one is the literal differentiator
export function query(db: string, table: "users"): ExtA
export function query(db: string, table: "posts"): ExtA
export function query(db: string, table: string): ExtA { return {} as any }

// Case 5: Overload with string catchall alongside literals
export function lookup(key: "name"): string
export function lookup(key: "age"): number
export function lookup(key: string): any { return {} }

// Case 6: Non-literal overloads that collapse (different interfaces → JsObject)
export function process(input: ExtA): void
export function process(input: ExtB): void
export function process(input: ExtA | ExtB): void {}

// Case 9: Single overload (no collision)
export function single(name: "only"): string
export function single(name: string): string { return "" }

// Case 10: Two overloads that DON'T collide (different param counts)
export function multi(a: string): void
export function multi(a: string, b: number): void
export function multi(a: string, b?: number): void {}

// Case 11: Numeric literal type overloads
export function getChannel(id: 0): ExtA
export function getChannel(id: 1): ExtB
export function getChannel(id: 2): ExtC
export function getChannel(id: number): any { return {} }

// Case 12: Boolean literal type overloads
export function toggle(state: true): ExtA
export function toggle(state: false): ExtB
export function toggle(state: boolean): any { return {} }

// Case 7: Method overloads on an interface (the WebGL getExtension pattern)
export interface Renderer {
  getFeature(name: "EXT_A"): ExtA
  getFeature(name: "EXT_B"): ExtB
  getFeature(name: "EXT_C"): ExtC
}

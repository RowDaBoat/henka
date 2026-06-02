// Functions: free functions with importjs
export function add(a: number, b: number): number { return a + b }
export function greet(name: string): string { return "" }
export function toggle(flag: boolean): boolean { return !flag }
export function noop(): void {}
export function noAnnotation() {}

// Variables and constants
export const PI = 3.14159
export const GREETING = "hello"

// Type mappings: primitives
export function useNumber(x: number): number { return x }
export function useString(x: string): string { return x }
export function useBool(x: boolean): boolean { return x }
export function useVoid(): void {}
export function useAny(x: any): any { return x }

// Arrays: T[] and Array<T>
export function sumArray(items: number[]): number { return 0 }
export function concatArrays(a: Array<string>, b: string[]): Array<string> { return [] }

// Callbacks / function types
export type Callback = (x: number) => void
export type Predicate = (item: string, index: number) => boolean
export function forEach(items: number[], cb: (item: number) => void): void {}

// Union types
export function parseUnion(input: string | number): string { return "" }
export function flexUnion(a: string | number | boolean): void {}

// Optional types: T | undefined, x?: T
export function tryFind(items: string[]): string | undefined { return undefined }
export function configure(host: string, port?: number, timeout?: number): void {}

// Default parameter values
export function greetDefault(name: string = "World"): string { return "" }
export function repeatDefault(text: string, count: number = 1): string { return "" }
export function logDefault(message: string, level: string = "info", verbose: boolean = false): void {}

// Rest parameters
export function logRest(message: string, ...args: string[]): void {}
export function sumRest(...numbers: number[]): number { return 0 }

// Promise / async
export function fetchData(url: string): Promise<string> { return Promise.resolve("") }
export async function loadAsync(path: string): Promise<number> { return 0 }

// Generic types fallback
export function getMap(): Map<string, number> { return new Map() }
export function getSet(): Set<string> { return new Set() }

// Interface: fields only
export interface Point {
  x: number
  y: number
}

// Interface: with methods
export interface Logger {
  level: string
  log(message: string): void
  error(message: string, code: number): void
}

// Interface: with optional fields
export interface Settings {
  host: string
  port?: number
  debug?: boolean
}

// Interface: with callbacks and async
export interface HttpClient {
  get(url: string): Promise<string>
  post(url: string, body: string): Promise<number>
  onError(handler: (error: string) => void): void
}

// Nested/anonymous object types → synthetic AnonymousN types
export function createWindow(config: { width: number, height: number, title: string }): void {}
export interface AppConfig {
  window: { width: number, height: number }
  debug: { verbose: boolean }
}

// Type alias: object literal
export type Color = {
  r: number
  g: number
  b: number
  a: number
}

// Type alias: primitive alias
export type Identifier = string

// Type alias: callback alias
export type EventHandler = (event: string, data: any) => void

// Class: fields, constructor, instance methods, static methods
export class Vec3 {
  x: number
  y: number
  z: number

  constructor(x: number, y: number, z: number) {
    this.x = x; this.y = y; this.z = z
  }

  length(): number { return 0 }
  add(other: Vec3): Vec3 { return this }
  scale(s: number): Vec3 { return this }
  static zero(): Vec3 { return new Vec3(0, 0, 0) }
}

// Enum: numeric auto-increment
export enum Direction {
  Up,
  Down,
  Left,
  Right,
}

// Enum: numeric explicit values
export enum Color2 {
  Red = 0xFF0000,
  Green = 0x00FF00,
  Blue = 0x0000FF,
}

// Enum: string values
export enum Status {
  Active = "active",
  Inactive = "inactive",
  Pending = "pending",
}

// Enum used as parameter type
export function move(dir: Direction): void {}
export function setStatus(s: Status): void {}

// Class inheritance
export class BaseEntity {
  id: string
  constructor(id: string) { this.id = id }
}
export class Player extends BaseEntity {
  name: string
  constructor(id: string, name: string) { super(id); this.name = name }
  greet(): string { return "" }
}

// Interface inheritance
export interface Serializable {
  serialize(): string
}
export interface Storable extends Serializable {
  store(key: string): void
}

// Overloaded functions
export function stringify(value: number): string
export function stringify(value: boolean): string
export function stringify(value: number | boolean): string { return "" }

// Namespace declarations
export namespace Util {
  export function clamp(value: number, min: number, max: number): number { return 0 }

  export interface Range {
    min: number
    max: number
  }

  export namespace Math {
    export function lerp(a: number, b: number, t: number): number { return 0 }
  }
}

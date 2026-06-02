export interface Logger {
  level: string
  log(message: string): void
  warn(message: string): void
  error(message: string, code: number): void
}

export interface Storage {
  get(key: string): string
  set(key: string, value: string): void
  delete(key: string): boolean
  readonly size: number
}

export interface Config {
  host: string
  port: number
}

export interface EventTarget {
  "abort": string
  "click": string
  normal: string
}


export interface Config {
  host: string
  port: number
}

export function getKey<K extends keyof Config>(key: K): Config[K] { return {} as any }
export function identity<T>(value: T): T { return value }

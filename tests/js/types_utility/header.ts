interface Config {
  host: string
  port: number
}

type Handler = (event: string) => void

// Object wrappers
export function partial(config: Partial<Config>): void {}
export function required(config: Required<Config>): void {}
export function readonly(config: Readonly<Config>): Config { return config }
export function nonNull(value: NonNullable<string | null>): string { return value }

// Key/value selectors
export function pick(config: Pick<Config, "host">): void {}
export function omit(config: Omit<Config, "port">): void {}
export function record(map: Record<string, number>): void {}
export function extract(value: Extract<string | number, string>): void {}
export function exclude(value: Exclude<string | number, string>): void {}

// Function manipulation
export function retType(value: ReturnType<Handler>): void {}
export function params(value: Parameters<Handler>): void {}
export function instType(value: InstanceType<typeof Error>): void {}

// Promise/Async
export function awaited(value: Awaited<Promise<string>>): void {}

// Iteration
export function iterate(items: Iterable<string>): void {}
export function iterator(items: Iterator<string>): void {}
export function iterableIterator(items: IterableIterator<string>): void {}
export function asyncIterable(items: AsyncIterable<string>): void {}
export function asyncIterator(items: AsyncIterator<string>): void {}
export function asyncIterableIterator(items: AsyncIterableIterator<string>): void {}

// Collections
export function useMap(map: Map<string, number>): void {}
export function useSet(set: Set<string>): void {}
export function useWeakMap(map: WeakMap<object, string>): void {}
export function useWeakSet(set: WeakSet<object>): void {}

// Keywords
export function getKeys(obj: object): void {}
export function getUnknown(value: unknown): void {}
export function getAny(value: any): void {}

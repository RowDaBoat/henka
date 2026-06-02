export function throwError(): never { throw new Error() }
export function assertNever(value: never): never { throw new Error() }

export interface Exhaustive {
  check(value: never): void
  fail(): never
}

export type EmptyUnion = never

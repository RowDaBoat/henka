export function getBigInt(): bigint { return BigInt(0) }
export function useBigInt(value: bigint): void {}

export interface Counter {
  count: bigint
}

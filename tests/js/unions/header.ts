export function parse(input: string | number): string { return "" }
export function coerce(value: string | boolean): number { return 0 }
export function flex(a: string | number | boolean): void {}

export interface Flexible {
  value: string | number
  convert(input: string | number): string
}

export type PowerPref = "default" | "high-performance" | "low-power"
export function setPower(pref: PowerPref): void {}

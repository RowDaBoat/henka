export interface Config {
  mode: ColorMode
  size: Size
  label: string
}

export function setMode(mode: ColorMode): void {}
export function setSize(size: Size): void {}
export function configure(config: Config): void {}

export type ColorMode = "light" | "dark" | "auto"
export type Size = "small" | "medium" | "large"

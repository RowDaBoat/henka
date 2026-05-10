export interface ElementMap {
  "annotation-xml": string
  "color-profile": string
  "font-face": string
  normal: string
}

export interface JQueryLike {
  $element: string
  $$ref: string
  get$value(): string
}

export function $init(): void {}
export function $$reset(): void {}

export type AutoFillBase = "" | "off" | "on"
export function setAutoFill(value: AutoFillBase): void {}

export interface TrailingUnderscore {
  value_: string
  data__: string
}

export type MimeType = "application/json" | "application/xhtml+xml" | "text/plain"
export function setMime(value: MimeType): void {}

export interface Keywords {
  type: string
  object: string
  import: string
  export: string
  proc: string
  var: string
  let: string
  const: string
  yield: string
  discard: string
  end: string
}

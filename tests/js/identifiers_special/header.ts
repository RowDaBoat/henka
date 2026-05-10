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

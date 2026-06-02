export interface Decoder {
  decode(input: ArrayBuffer): string
  buffer: SharedArrayBuffer
}

export function readFile(path: string): ArrayBuffer { return new ArrayBuffer(0) }
export function upload(data: Blob): void {}

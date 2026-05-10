export interface FileReader {
  error: DOMException
  onabort: ((this: FileReader, ev: ProgressEvent) => any) | null
  onload: ((this: FileReader, ev: ProgressEvent) => any) | null
  result: string | null
}

export interface DOMException {
  message: string
}

export interface ProgressEvent {
  loaded: number
  total: number
}

export interface EventTarget {
  onclick: ((ev: MouseEvent) => void) | null
  onerror: ((ev: ErrorEvent) => any) | null
}

export interface MouseEvent { x: number; y: number }
export interface ErrorEvent { message: string }

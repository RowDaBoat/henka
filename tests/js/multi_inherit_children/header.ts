export interface Readable {
  read(): string
}

export interface Writable {
  write(data: string): void
}

export interface Stream extends Readable, Writable {
  name: string
}

export interface FileStream extends Stream {
  path: string
}

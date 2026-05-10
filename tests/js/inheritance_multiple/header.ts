export interface Readable {
  read(): string
}

export interface Writable {
  write(data: string): void
}

export interface Closeable {
  close(): void
}

export interface Stream extends Readable, Writable, Closeable {
  name: string
}

export class Node {
  textContent: string
  appendChild(child: Node): void {}
}

export class Element extends Node {
  innerHTML: string
  id: string
  setAttribute(name: string, value: string): void {}
}

export class HTMLElement extends Element {
  style: string
  className: string
  addEventListener(event: string, handler: (e: any) => void): void {}
}

export interface Readable {
  read(): string
}

export interface Writable {
  write(data: string): void
}

export interface ReadWritable extends Readable {
  write(data: string): void
}

export interface Collection<T> {
  get(index: number): T
}

export interface StringList extends Collection<string> {
  join(separator: string): string
}

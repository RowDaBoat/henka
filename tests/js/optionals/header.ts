export function find(items: string[], pred: (item: string) => boolean): string | undefined { return undefined }
export function tryParse(input: string): number | undefined { return undefined }

export interface Config {
  host: string
  port?: number
  timeout?: number
  label?: string
}

export function configure(host: string, port?: number, timeout?: number): void {}

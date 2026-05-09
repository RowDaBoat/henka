export function fetchData(url: string): Promise<string> { return Promise.resolve("") }
export function fetchCount(url: string): Promise<number> { return Promise.resolve(0) }
export function ping(host: string): Promise<void> { return Promise.resolve() }
export async function load(path: string): Promise<string> { return "" }

export interface HttpClient {
  get(url: string): Promise<string>
  post(url: string, body: string): Promise<number>
}

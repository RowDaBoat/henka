export function createWindow(config: { width: number, height: number, title: string }): void {}
export function draw(shape: { x: number, y: number }, color: { r: number, g: number, b: number }): void {}

export interface App {
  window: { width: number, height: number }
  settings: { debug: boolean, verbose: boolean }
}

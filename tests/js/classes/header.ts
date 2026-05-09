export class Vec3 {
  x: number
  y: number
  z: number

  constructor(x: number, y: number, z: number) {
    this.x = x
    this.y = y
    this.z = z
  }

  length(): number {
    return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z)
  }

  add(other: Vec3): Vec3 {
    return new Vec3(this.x + other.x, this.y + other.y, this.z + other.z)
  }

  scale(s: number): Vec3 {
    return new Vec3(this.x * s, this.y * s, this.z * s)
  }

  static zero(): Vec3 {
    return new Vec3(0, 0, 0)
  }
}

export class Renderer {
  canvas: string
  width: number
  height: number

  constructor(canvas: string, width: number, height: number) {
    this.canvas = canvas
    this.width = width
    this.height = height
  }

  clear(): void {
  }

  drawLine(from: Vec3, to: Vec3): void {
  }
}

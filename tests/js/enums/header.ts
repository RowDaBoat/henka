export enum Direction {
  Up,
  Down,
  Left,
  Right,
}

export enum Color {
  Red = 0xFF0000,
  Green = 0x00FF00,
  Blue = 0x0000FF,
}

export enum Status {
  Active = "active",
  Inactive = "inactive",
  Pending = "pending",
}

export function move(dir: Direction): void {}

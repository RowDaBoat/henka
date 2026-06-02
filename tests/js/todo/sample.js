/**
 * @param {number} a
 * @param {number} b
 * @returns {number}
 */
export function add(a, b) {
  return a + b
}

/**
 * @param {string} name
 * @returns {string}
 */
export function greet(name) {
  return "Hello, " + name
}

export const PI = 3.14159

/**
 * @param {{ x: number, y: number }} v
 * @returns {number}
 */
export function magnitude(v) {
  return Math.sqrt(v.x * v.x + v.y * v.y)
}

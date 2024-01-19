/**
 * Random String generator
 * @returns String
 */
export function randomString(): string {
  return Math.random().toString(36).slice(2, 22);
}

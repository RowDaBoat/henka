export type SectionId = `section-${string}`
export function getSection(): SectionId { return "section-main" }

export interface Config {
  prefix: `data-${string}`
}

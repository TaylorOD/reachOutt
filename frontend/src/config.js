export const isPreview = import.meta.env.VITE_PR_PREVIEW === 'true'

export function assetPath(path) {
  return `${import.meta.env.BASE_URL}${path}`
}

const destinations = new Set(['/contact', '/reachout', '/account', '/account/password'])

// Only application pages can be used as a destination after authentication.
export function loginDestination(value) {
  if (typeof value !== 'string' || !value.startsWith('/') || value.startsWith('//'))
    return '/reachout'
  const url = new URL(value, 'https://reachoutt.invalid')
  if (url.origin !== 'https://reachoutt.invalid' || !destinations.has(url.pathname))
    return '/reachout'
  return url.pathname + url.search
}

export function authRoute(path, returnTo) {
  return { path, query: returnTo ? { returnTo: loginDestination(returnTo) } : {} }
}

export function expiredSessionUrl(location, development = false) {
  const path = development ? location.pathname.replace(/^\/app(?=\/)/, '') : location.pathname
  const destination = loginDestination(path + location.search)
  return `${development ? '/app' : ''}/login?${new URLSearchParams({ returnTo: destination })}`
}

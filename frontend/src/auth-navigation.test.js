import { expect, it } from 'vitest'
import { authRoute, expiredSessionUrl, loginDestination } from './auth-navigation'

it('keeps owned application destinations and contact selections', () => {
  expect(loginDestination('/contact')).toBe('/contact')
  expect(loginDestination('/reachout?contact=42')).toBe('/reachout?contact=42')
  expect(authRoute('/signup', '/account')).toEqual({
    path: '/signup',
    query: { returnTo: '/account' }
  })
  expect(authRoute('/login')).toEqual({ path: '/login', query: {} })
})

it('rejects external destinations and authentication loops', () => {
  for (const path of [
    undefined,
    [],
    'https://example.com',
    '//example.com',
    '/\\example.com',
    '/login',
    '/logout',
    '/reset-password#token',
    '/unknown',
    '/contact/../logout'
  ]) {
    expect(loginDestination(path)).toBe('/reachout')
  }
})

it('keeps the interrupted page after session expiry in production and development', () => {
  expect(expiredSessionUrl({ pathname: '/reachout', search: '?contact=42' })).toBe(
    '/login?returnTo=%2Freachout%3Fcontact%3D42'
  )
  expect(expiredSessionUrl({ pathname: '/app/account', search: '' }, true)).toBe(
    '/app/login?returnTo=%2Faccount'
  )
})

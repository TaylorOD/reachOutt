import { test, expect } from '@playwright/test'

async function openNavigation(page, mobile) {
  if (mobile) await page.getByRole('button', { name: 'Toggle navigation' }).click()
}

test('navigation follows login state and the account disclosure works by keyboard', async ({
  page
}, testInfo) => {
  const mobile = testInfo.project.name === 'mobile'
  const email = `nav-menu-${testInfo.project.name}-${Date.now()}@example.test`
  await page.request.post('/api/users', { data: { email, password: 'navigation test password' } })
  await page.goto('/login')
  await openNavigation(page, mobile)
  const nav = page.getByRole('navigation', { name: 'Main navigation' })
  await expect(nav.getByRole('link', { name: 'Signup', exact: true })).toBeVisible()
  await expect(nav.getByRole('link', { name: 'Contacts', exact: true })).toHaveCount(0)
  await page.getByLabel('email', { exact: true }).fill(email)
  await page.getByLabel('password', { exact: true }).fill('navigation test password')
  await page.getByRole('button', { name: 'Submit' }).click()
  await expect(page).toHaveURL((url) => url.pathname === '/reachout')
  await openNavigation(page, mobile)
  await expect(nav.getByRole('link', { name: 'Login', exact: true })).toHaveCount(0)
  await expect(nav.getByRole('link', { name: 'Contacts', exact: true })).toBeVisible()
  const toggle = nav.getByRole('button', { name: 'Account', exact: true })
  await toggle.press('Enter')
  await expect(toggle).toHaveAttribute('aria-expanded', 'true')
  await nav.getByRole('link', { name: 'Profile', exact: true }).press('Escape')
  await expect(toggle).toBeFocused()
  await expect(toggle).toHaveAttribute('aria-expanded', 'false')
  await toggle.click()
  await page.screenshot({
    path: `test-results/${testInfo.project.name}-navigation.png`,
    fullPage: false
  })
  await nav.getByRole('link', { name: 'Password', exact: true }).click()
  await expect(page).toHaveURL(/\/account#account-password-title$/)
  await expect(page.getByRole('heading', { name: 'Password', exact: true })).toBeInViewport()
  await openNavigation(page, mobile)
  await toggle.click()
  await nav.getByRole('link', { name: 'Log out', exact: true }).click()
  await expect(page).toHaveURL((url) => url.pathname === '/')
  await openNavigation(page, mobile)
  await expect(nav.getByRole('link', { name: 'Login', exact: true })).toBeVisible()
  await expect(toggle).toHaveCount(0)
})

test('logging out in another tab hides private navigation and content', async ({
  page,
  context
}) => {
  const email = `nav-tabs-${Date.now()}@example.test`
  await page.request.post('/api/users', { data: { email, password: 'navigation test password' } })
  const response = await page.request.post('/api/sessions', {
    data: { email, password: 'navigation test password' }
  })
  const { jwt } = await response.json()
  await page.goto('/login')
  await page.evaluate((token) => localStorage.setItem('jwt', token), jwt)
  await page.goto('/account')
  await expect(page.getByLabel('Email', { exact: true })).toHaveValue(email)
  const other = await context.newPage()
  await other.goto('/logout')
  await expect(page).toHaveURL(
    (url) => url.pathname === '/login' && url.searchParams.get('returnTo') === '/account'
  )
  await expect(page.getByRole('heading', { name: 'Account', exact: true })).toHaveCount(0)
})

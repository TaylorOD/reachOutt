import { test, expect } from '@playwright/test'

async function login(page, email) {
  await page.getByLabel('email', { exact: true }).fill(email)
  await page.getByLabel('password', { exact: true }).fill('navigation test password')
  await page.getByRole('button', { name: 'Submit' }).click()
}

test('login restores a contact selection and rejects external return destinations', async ({
  page
}, testInfo) => {
  const email = `navigation-${testInfo.project.name}-${Date.now()}@example.test`
  await page.request.post('/api/users', { data: { email, password: 'navigation test password' } })
  const response = await page.request.post('/api/sessions', {
    data: { email, password: 'navigation test password' }
  })
  const { jwt } = await response.json()
  const contact = await page.request.post('/api/contacts', {
    headers: { Authorization: `Bearer ${jwt}` },
    data: { first_name: 'Sam' }
  })
  const { id } = await contact.json()
  await page.goto(`/reachout?contact=${id}`)
  await expect(page).toHaveURL(/\/login\?returnTo=/)
  await login(page, email)
  await expect(page).toHaveURL(new RegExp(`/reachout\\?contact=${id}$`))
  await expect(page.getByRole('dialog')).toBeVisible()
  await expect(page.getByLabel('New ContactID')).toHaveValue(String(id))
  await page.screenshot({
    path: `test-results/${testInfo.project.name}-login-return.png`,
    fullPage: false,
    scale: 'css'
  })
  await page.goto('/logout')
  await page.goto('/login?returnTo=https%3A%2F%2Fexample.com')
  await login(page, email)
  await expect(page).toHaveURL(/\/reachout$/)
})

test('signup keeps the requested page and expired sessions return to it', async ({
  page
}, testInfo) => {
  const email = `signup-nav-${testInfo.project.name}-${Date.now()}@example.test`
  await page.goto('/contact')
  await page.getByRole('link', { name: 'Create an account' }).click()
  await page.getByLabel('email', { exact: true }).fill(email)
  await page.getByLabel('password', { exact: true }).fill('navigation test password')
  await page.getByLabel('passwordConfirmation').fill('navigation test password')
  await page.getByRole('button', { name: 'Submit' }).click()
  await expect(page).toHaveURL(/\/login\?returnTo=(?:%2F|\/)contact$/)
  await login(page, email)
  await expect(page).toHaveURL((url) => url.pathname === '/contact')
  await page.evaluate(() => localStorage.setItem('jwt', 'expired-test-token'))
  await page.goto('/account')
  await expect(page).toHaveURL(/\/login\?returnTo=(?:%2F|\/)account$/)
  await login(page, email)
  await expect(page).toHaveURL(/\/account$/)
  await expect(page.getByLabel('Email', { exact: true })).toHaveValue(email)
})

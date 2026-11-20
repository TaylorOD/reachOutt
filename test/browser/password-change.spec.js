import { test, expect } from '@playwright/test'

test('password changes validate entries and require a fresh login', async ({ page }, testInfo) => {
  const email = `password-change-${testInfo.project.name}-${Date.now()}@example.test`
  await page.request.post('/api/users', { data: { email, password: 'original test password' } })
  const response = await page.request.post('/api/sessions', {
    data: { email, password: 'original test password' }
  })
  const { jwt } = await response.json()
  await page.goto('/login')
  await page.evaluate((token) => localStorage.setItem('jwt', token), jwt)
  await page.goto('/account#account-password-title')
  const form = page.getByRole('region', { name: 'Password', exact: true })
  await form.getByLabel('Current password', { exact: true }).fill('wrong current password')
  await form.getByLabel('New password', { exact: true }).fill('updated test password')
  await form.getByLabel('Confirm new password', { exact: true }).fill('does not match')
  await form.getByRole('button', { name: 'Change password', exact: true }).click()
  await expect(form.getByRole('alert')).toHaveText('Your new passwords do not match.')
  await form.getByLabel('Confirm new password', { exact: true }).fill('updated test password')
  await form.getByRole('button', { name: 'Change password', exact: true }).click()
  await expect(form.getByRole('alert')).toHaveText('Your current password is incorrect.')
  await form.getByLabel('Current password', { exact: true }).fill('original test password')
  await form.getByLabel('Show passwords').check()
  await expect(form.getByLabel('New password', { exact: true })).toHaveAttribute('type', 'text')
  await form.getByLabel('Show passwords').uncheck()
  await form.getByRole('button', { name: 'Change password', exact: true }).click()
  await expect(page).toHaveURL(
    (url) => url.pathname === '/login' && url.searchParams.get('passwordChanged') === '1'
  )
  await expect(page.getByRole('status')).toHaveText(
    'Password changed. Log in with your new password.'
  )
  const oldSession = await page.request.get('/api/account', {
    headers: { Authorization: `Bearer ${jwt}` }
  })
  expect(oldSession.status()).toBe(401)
  await page.getByLabel('email', { exact: true }).fill(email)
  await page.getByLabel('password', { exact: true }).fill('original test password')
  await page.getByRole('button', { name: 'Submit' }).click()
  await expect(page.getByRole('alert')).toHaveText('Invalid email or password.')
  await page.getByLabel('email', { exact: true }).fill(email)
  await page.getByLabel('password', { exact: true }).fill('updated test password')
  await page.getByRole('button', { name: 'Submit' }).click()
  await expect(page).toHaveURL((url) => url.pathname === '/account')
  await expect(page.getByLabel('Email', { exact: true })).toHaveValue(email)
})

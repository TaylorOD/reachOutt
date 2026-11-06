import { test, expect } from '@playwright/test'

test('public pages load their assets and show login errors', async ({ page }, testInfo) => {
  const failures = []
  page.on('response', (response) => {
    if (response.status() >= 400 && !response.url().includes('/api/sessions'))
      failures.push(response.url())
  })
  for (const route of ['about', 'signup', 'login']) {
    await page.goto(`/${route}`)
    await expect(page.locator('h1').first()).toBeVisible()
    await page.screenshot({
      path: `test-results/${testInfo.project.name}-${route}.png`,
      fullPage: true,
      scale: 'css'
    })
  }
  await page.getByLabel('email', { exact: true }).fill('missing@example.test')
  await page.getByLabel('password', { exact: true }).fill('wrong password')
  await page.getByRole('button', { name: 'Submit' }).click()
  await expect(page.getByText('Invalid email or password.')).toBeVisible()
  expect(failures).toEqual([])
})

test('signup login contacts and reminders work together', async ({ page }, testInfo) => {
  const errors = []
  page.on('pageerror', (error) => errors.push(error.message))
  const email = `browser-${testInfo.project.name}-${Date.now()}@example.test`
  await page.goto('/')
  await expect(page.getByRole('heading', { name: /Hello/ })).toBeVisible()
  await expect(page.locator('script[type=module]')).toHaveAttribute('src', /^\/app\/assets\//)
  await page.screenshot({
    path: `test-results/${testInfo.project.name}-home.png`,
    fullPage: true,
    scale: 'css'
  })
  await page.goto('/signup')
  await page.getByLabel('first name', { exact: true }).fill('Alex')
  await page.getByLabel('last name', { exact: true }).fill('Example')
  await page.getByLabel('phone number', { exact: true }).fill('+15005550006')
  await page.getByLabel('email', { exact: true }).fill(email)
  await page.getByLabel('password', { exact: true }).fill('browser test password')
  await page.getByLabel('passwordConfirmation', { exact: true }).fill('browser test password')
  await page.getByRole('button', { name: 'Submit' }).click()
  await expect(page).toHaveURL(/\/login$/)
  await page.getByLabel('email', { exact: true }).fill(email)
  await page.getByLabel('password', { exact: true }).fill('browser test password')
  await page.getByRole('button', { name: 'Submit' }).click()
  await expect(page).toHaveURL('http://127.0.0.1:3000/')
  if (testInfo.project.name === 'mobile')
    await page.getByRole('button', { name: 'Toggle navigation' }).click()
  await page.getByRole('link', { name: '03: Contacts' }).click()
  await page.getByLabel('New FirstName', { exact: true }).fill('Sam')
  await page.getByLabel('New LastName', { exact: true }).fill('Example')
  await page.getByLabel('New PhoneNumber', { exact: true }).fill('2025550100')
  await page.getByRole('button', { name: 'Create Contact' }).click()
  await expect(page.getByRole('heading', { name: 'Sam Example' })).toBeVisible()
  await page.screenshot({
    path: `test-results/${testInfo.project.name}-contacts.png`,
    fullPage: true,
    scale: 'css'
  })
  await page.getByRole('button', { name: 'Edit Contact' }).click()
  await page.getByLabel('Edit first name').fill('Taylor')
  await page.getByRole('dialog').getByRole('button', { name: 'Close', exact: true }).click()
  await expect(page.getByRole('heading', { name: 'Sam Example' })).toBeVisible()
  await page.goto('/reachout')
  await page.getByLabel('New Frequency', { exact: true }).selectOption('7d')
  await page.getByLabel('New ContactID', { exact: true }).selectOption({ label: 'Sam Example' })
  await page.getByLabel('New Topic', { exact: true }).selectOption('News')
  await page.getByLabel('New StartDate', { exact: true }).fill('2027-01-01')
  await page.getByRole('button', { name: 'Create Reachout' }).click()
  await expect(page.getByText('Topic: News', { exact: true })).toBeVisible()
  await page.getByRole('button', { name: 'Edit Reachout' }).click()
  await expect(page.getByRole('dialog')).toContainText('Contact Name: Sam Example')
  await expect(page.getByLabel('Edit contact id', { exact: true })).toHaveCount(0)
  await page.getByLabel('Edit topic', { exact: true }).selectOption('Sports')
  await page.screenshot({
    path: `test-results/${testInfo.project.name}-edit.png`,
    fullPage: false,
    scale: 'css'
  })
  await page.getByRole('button', { name: 'Update', exact: true }).click()
  await expect(page.getByText('Topic: Sports', { exact: true })).toBeVisible()
  await page.reload()
  await expect(page.getByText('Topic: Sports', { exact: true })).toBeVisible()
  await page.screenshot({
    path: `test-results/${testInfo.project.name}-reachouts.png`,
    fullPage: true
  })
  await page.getByRole('button', { name: 'Edit Reachout' }).click()
  await page.getByRole('button', { name: 'Destroy', exact: true }).click()
  await expect(page.getByText('Topic: Sports', { exact: true })).toHaveCount(0)
  await page.goto('/contact')
  await page.getByRole('button', { name: 'Edit Contact' }).click()
  await page.getByRole('button', { name: 'Destroy', exact: true }).click()
  await expect(page.getByRole('heading', { name: 'Sam Example' })).toHaveCount(0)
  await page.goto('/logout')
  await page.goto('/contact')
  await expect(page).toHaveURL(/\/login$/)
  expect(errors).toEqual([])
})

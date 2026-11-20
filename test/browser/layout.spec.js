import { test, expect } from '@playwright/test'

test('populated lists support search, filters and readable layouts', async ({ page }, testInfo) => {
  const email = `layout-${testInfo.project.name}-${Date.now()}@example.test`
  await page.request.post('/api/users', { data: { email, password: 'layout test password' } })
  const login = await page.request.post('/api/sessions', {
    data: { email, password: 'layout test password' }
  })
  const { jwt } = await login.json()
  const headers = { Authorization: `Bearer ${jwt}` }
  for (const [index, first_name] of [
    'Sam',
    'AlexandriaWithAnExceptionallyLongName',
    'Jamie',
    'Riley'
  ].entries()) {
    const response = await page.request.post('/api/contacts', {
      headers,
      data: { first_name, last_name: 'Example', phone_number: `202555010${index}` }
    })
    const contact = await response.json()
    const reminder = await page.request.post('/api/reachouts', {
      headers,
      data: { contact_id: contact.id, frequency: '7d', start_date: '2030-01-01' }
    })
    if (index % 2)
      await page.request.patch(`/api/reachouts/${(await reminder.json()).id}`, {
        headers,
        data: { enabled: false }
      })
  }
  await page.goto('/login')
  await page.getByLabel('email', { exact: true }).fill(email)
  await page.getByLabel('password', { exact: true }).fill('layout test password')
  await page.getByRole('button', { name: 'Submit' }).click()
  await expect(page).toHaveURL(/\/reachout$/)
  if (testInfo.project.name === 'mobile')
    await page.getByRole('button', { name: 'Toggle navigation' }).click()
  await page.getByRole('link', { name: 'Contacts', exact: true }).click()
  await expect(page.getByRole('article')).toHaveCount(4)
  await expectNoOverflow(page)
  await page.getByRole('searchbox', { name: 'Search contacts' }).fill('sam')
  await expect(page.getByRole('article')).toHaveCount(1)
  await expect(page.getByRole('heading', { name: 'Sam Example' })).toBeVisible()
  await page.getByRole('searchbox').fill('nobody')
  await expect(page.getByText('No matching contacts')).toBeVisible()
  await page.getByRole('button', { name: 'Clear search' }).click()
  await expect(page.getByRole('article')).toHaveCount(4)
  await page.getByRole('searchbox').fill('0102')
  await expect(page.getByRole('heading', { name: 'Jamie Example' })).toBeVisible()
  await page.goto('/reachout')
  await expect(page.getByRole('article')).toHaveCount(4)
  await expectNoOverflow(page)
  await page.getByLabel('Filter reminders').selectOption('paused')
  await expect(page.getByRole('article')).toHaveCount(2)
  await expect(page.getByRole('button', { name: 'Resume reminder' })).toHaveCount(2)
  await page.getByLabel('Filter reminders').selectOption('active')
  await expect(page.getByRole('article')).toHaveCount(2)
  await page.getByRole('button', { name: 'Edit Reachout' }).first().click()
  const dialog = page.getByRole('dialog')
  await expect(dialog).toBeVisible()
  const bounds = await dialog.boundingBox()
  const viewport = page.viewportSize()
  expect(bounds.x).toBeGreaterThanOrEqual(0)
  expect(bounds.y).toBeGreaterThanOrEqual(0)
  expect(bounds.width).toBeLessThanOrEqual(viewport.width)
  expect(bounds.height).toBeLessThanOrEqual(viewport.height)
  await dialog.getByRole('button', { name: 'Close', exact: true }).click()
  await expect(dialog).not.toBeVisible()
})

async function expectNoOverflow(page) {
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(
    true
  )
  for (const card of await page.getByRole('article').all()) {
    const bounds = await card.boundingBox()
    for (const button of await card.getByRole('button').all()) {
      const control = await button.boundingBox()
      expect(control.x).toBeGreaterThanOrEqual(bounds.x)
      expect(control.x + control.width).toBeLessThanOrEqual(bounds.x + bounds.width + 1)
      expect(control.y + control.height).toBeLessThanOrEqual(bounds.y + bounds.height + 1)
    }
  }
}

test('empty contacts have one next step and failed loads can be retried', async ({
  page
}, testInfo) => {
  const email = `empty-${testInfo.project.name}-${Date.now()}@example.test`
  await page.request.post('/api/users', { data: { email, password: 'empty test password' } })
  await page.goto('/login')
  await page.getByLabel('email', { exact: true }).fill(email)
  await page.getByLabel('password', { exact: true }).fill('empty test password')
  await page.getByRole('button', { name: 'Submit' }).click()
  await expect(page).toHaveURL(/\/reachout$/)
  await page.route('**/api/contacts', (route) => route.fulfill({ status: 503, body: '{}' }), {
    times: 1
  })
  await page.goto('/contact')
  await expect(page.getByRole('heading', { name: 'Your contacts could not load' })).toBeVisible()
  await expect(page.getByRole('button', { name: 'Add your first contact' })).toHaveCount(0)
  await page.getByRole('button', { name: 'Try again' }).click()
  await expect(page.getByRole('button', { name: 'Add your first contact' })).toBeVisible()
  await expect(page.getByRole('button', { name: 'Add contact', exact: true })).toHaveCount(0)
  await page.getByRole('button', { name: 'Add your first contact' }).click()
  await expect(page.getByRole('dialog', { name: 'New contact' })).toBeVisible()
})

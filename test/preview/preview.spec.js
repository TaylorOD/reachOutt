import { test, expect } from '@playwright/test'

test('nested previews load fictional screens without API requests', async ({ page }, testInfo) => {
  const failures = []
  const apiRequests = []
  page.on('response', response => { if (response.status() >= 400) failures.push(response.url()) })
  page.on('request', request => { if (request.url().includes('/api/')) apiRequests.push(request.url()) })
  page.on('pageerror', error => failures.push(error.message))
  for (const route of ['/', '/about', '/contact', '/reachout', '/account']) {
    await page.goto(`./#${route}`)
    await expect(page.getByText('PR preview. Fictional data. Changes, emails and texts are disabled.')).toBeVisible()
    if (route === '/contact') await expect(page.getByRole('heading', { name: 'Sam Example' })).toBeVisible()
    if (route === '/reachout') await expect(page.getByText('Status: Paused')).toBeVisible()
    if (route === '/account') await expect(page.getByLabel('Email', { exact: true })).toHaveValue('alex@example.test')
    await expect.poll(() => page.locator('img').evaluateAll(images => images.every(image => image.complete && image.naturalWidth > 0))).toBe(true)
  }
  await page.getByLabel('First name', { exact: true }).fill('Changed')
  await page.getByRole('button', { name: 'Save changes' }).click()
  await expect(page.getByRole('alert')).toContainText('fictional data')
  await page.reload()
  await expect(page.getByLabel('First name', { exact: true })).toHaveValue('Alex')
  await page.evaluate(() => window.scrollTo(0, 0))
  await page.screenshot({ path: `test-results/${testInfo.project.name}-preview.png`, fullPage: true, scale: 'css' })
  expect(apiRequests).toEqual([])
  expect(failures).toEqual([])
})

import { test, expect } from '@playwright/test'

test('request and reset forms handle success and invalid links', async ({ page }, testInfo) => {
  await page.goto('/login')
  await page.getByRole('link', { name: 'Forgot your password?' }).click()
  await page.getByLabel('Email', { exact: true }).fill('missing@example.test')
  await page.getByRole('button', { name: 'Send reset link' }).click()
  await expect(page.getByRole('status')).toContainText('If an account matches')
  await page.goto('/reset-password#invalid-token')
  await page.getByLabel('New password', { exact: true }).fill('a new long password')
  await page.getByLabel('Confirm password', { exact: true }).fill('a new long password')
  await page.getByRole('button', { name: 'Save password' }).click()
  await expect(page.getByRole('alert')).toContainText('invalid or expired')
  await expect(page).toHaveURL(/\/reset-password$/)
  await page.getByLabel('New password', { exact: true }).fill('')
  await page.getByLabel('Confirm password', { exact: true }).fill('')
  await page.evaluate(() => window.scrollTo(0, 0))
  await page.screenshot({
    path: `test-results/${testInfo.project.name}-password-reset.png`,
    fullPage: true,
    scale: 'css'
  })
})

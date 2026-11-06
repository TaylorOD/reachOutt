import { test, expect } from '@playwright/test'

test('pause and resume persist and deleting one reminder leaves the other', async ({
  page
}, testInfo) => {
  const email = `controls-${testInfo.project.name}-${Date.now()}@example.test`
  await page.request.post('/api/users', { data: { email, password: 'controls test password' } })
  const login = await page.request.post('/api/sessions', {
    data: { email, password: 'controls test password' }
  })
  const { jwt } = await login.json()
  const headers = { Authorization: `Bearer ${jwt}` }
  for (const first_name of ['Sam', 'Alex']) {
    const contact = await page.request.post('/api/contacts', { headers, data: { first_name } })
    const { id } = await contact.json()
    await page.request.post('/api/reachouts', {
      headers,
      data: { contact_id: id, frequency: '7d', start_date: '2030-01-01' }
    })
  }
  await page.goto('/login')
  await page.evaluate((token) => localStorage.setItem('jwt', token), jwt)
  await page.goto('/reachout')
  const sam = page.locator('.card-container').filter({ hasText: 'Contact Name: Sam' })
  const alex = page.locator('.card-container').filter({ hasText: 'Contact Name: Alex' })
  await sam.getByRole('button', { name: 'Pause reminder' }).click()
  await expect(sam).toContainText('Status: Paused')
  await page.reload()
  await expect(sam).toContainText('Status: Paused')
  await expect(alex).toContainText('Status: Active')
  await sam.scrollIntoViewIfNeeded()
  await page.screenshot({
    path: `test-results/${testInfo.project.name}-reminder-controls.png`,
    fullPage: true,
    scale: 'css'
  })
  await sam.getByRole('button', { name: 'Resume reminder' }).click()
  await expect(sam).toContainText('Status: Active')
  await sam.getByRole('button', { name: 'Edit Reachout' }).click()
  await page.getByRole('button', { name: 'Destroy', exact: true }).click()
  await expect(page.locator('dialog')).not.toBeVisible()
  await expect(sam).toHaveCount(0)
  await expect(alex).toBeVisible()
  await page.reload()
  await expect(sam).toHaveCount(0)
  await expect(alex).toBeVisible()
})

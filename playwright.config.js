import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './test/browser',
  fullyParallel: false,
  use: { baseURL: process.env.E2E_BASE_URL || 'http://127.0.0.1:3000', trace: 'retain-on-failure' },
  projects: [
    { name: 'desktop', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile', use: { ...devices['iPhone 13'], defaultBrowserType: 'chromium' } }
  ]
})

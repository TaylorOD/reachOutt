import { defineConfig, devices } from '@playwright/test'

const base = process.env.PREVIEW_BASE_PATH || '/reachOutt/pr-preview/pr-local/'
const url = `http://127.0.0.1:8087${base}`
export default defineConfig({
  testDir: './test/preview',
  use: { baseURL: url, trace: 'retain-on-failure' },
  webServer: {
    command: 'npm run preview -- --host 127.0.0.1 --port 8087',
    url,
    env: { PREVIEW_BASE_PATH: base },
    reuseExistingServer: !process.env.CI
  },
  projects: [
    { name: 'desktop', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile', use: { ...devices['iPhone 13'], defaultBrowserType: 'chromium' } }
  ]
})

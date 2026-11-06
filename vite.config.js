import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath } from 'node:url'

export default defineConfig({
  root: 'frontend',
  base: '/app/',
  plugins: [vue({ template: { transformAssetUrls: false } })],
  resolve: { alias: { '@': fileURLToPath(new URL('./frontend/src', import.meta.url)) } },
  server: { port: 8080, proxy: { '/api': 'http://127.0.0.1:3000' } },
  build: { outDir: '../public/app', emptyOutDir: true },
  test: { environment: 'jsdom', include: ['src/**/*.test.js'], clearMocks: true }
})

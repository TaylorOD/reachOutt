import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import api from './api'
import { isPreview } from './config'

if (isPreview) {
  const { previewAdapter } = await import('./preview')
  api.defaults.adapter = previewAdapter
}

const app = createApp(App)
app.use(router).mount('#app')

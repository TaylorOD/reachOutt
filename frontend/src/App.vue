<template>
  <div :class="{ 'preview-mode': preview }">
    <a class="skip-link" href="#main-content">Skip to content</a>
    <p v-if="preview" class="preview-banner" role="status">
      PR preview. Fictional data. Changes, emails and texts are disabled.
    </p>
    <SiteNav />
    <div id="main-content" tabindex="-1"><router-view /></div>
    <footer class="site-footer container">
      <span>ReachOutt.</span>
      <p>A little reminder. A real connection.</p>
    </footer>
  </div>
</template>

<script>
import { isPreview } from './config'
import SiteNav from './components/SiteNav.vue'

export default {
  components: { SiteNav },
  data() {
    return { preview: isPreview }
  }
}
</script>

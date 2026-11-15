<template>
  <div :class="{ 'preview-mode': preview }">
    <a class="skip-link" href="#main-content">Skip to content</a>
    <p v-if="preview" class="preview-banner" role="status">
      PR preview. Fictional data. Changes, emails and texts are disabled.
    </p>
    <header class="site-header">
      <nav class="container site-nav" aria-label="Main navigation">
        <router-link class="brand" to="/">ReachOutt<span aria-hidden="true">.</span></router-link>
        <button
          type="button"
          class="menu-toggle"
          :aria-expanded="menuOpen"
          aria-controls="site-menu"
          @click="menuOpen = !menuOpen"
          aria-label="Toggle navigation"
        >
          {{ menuOpen ? 'Close menu' : 'Menu' }}
        </button>
        <div id="site-menu" class="nav-links" :class="{ open: menuOpen }">
          <router-link to="/">Home</router-link><router-link to="/about">About</router-link>
          <template v-if="loggedIn"
            ><router-link to="/contact">Contacts</router-link
            ><router-link to="/reachout">Reachouts</router-link
            ><router-link to="/account">Account</router-link
            ><router-link class="nav-secondary" to="/logout">Logout</router-link></template
          >
          <template v-else
            ><router-link to="/login">Login</router-link
            ><router-link class="nav-signup" to="/signup">Signup</router-link></template
          >
        </div>
      </nav>
    </header>
    <div id="main-content" tabindex="-1"><router-view /></div>
    <footer class="site-footer container">
      <span>ReachOutt.</span>
      <p>A little reminder. A real connection.</p>
    </footer>
  </div>
</template>

<script>
import { isPreview } from './config'

export default {
  data() {
    return {
      menuOpen: false,
      preview: isPreview,
      loggedIn: isPreview || !!localStorage.getItem('jwt')
    }
  },
  watch: {
    $route() {
      this.menuOpen = false
      this.loggedIn = isPreview || !!localStorage.getItem('jwt')
    }
  }
}
</script>

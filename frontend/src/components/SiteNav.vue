<template>
  <header class="site-header">
    <nav class="container site-nav" aria-label="Main navigation" @keydown.esc="closeMenus">
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
        <template v-if="loggedIn">
          <router-link to="/contact">Contacts</router-link>
          <router-link to="/reachout">Reachouts</router-link>
          <div class="account-menu" ref="accountMenu">
            <button
              ref="accountToggle"
              type="button"
              class="account-toggle"
              :class="{ active: $route.path === '/account' }"
              :aria-expanded="accountOpen"
              aria-controls="account-links"
              @click="accountOpen = !accountOpen"
            >
              Account <span aria-hidden="true">{{ accountOpen ? '▴' : '▾' }}</span>
            </button>
            <div v-if="accountOpen" id="account-links" class="account-links">
              <router-link to="/account">Profile</router-link>
              <router-link to="/account#account-password-title">Password</router-link>
              <router-link to="/about">About ReachOutt</router-link>
              <router-link v-if="!preview" to="/logout">Log out</router-link>
            </div>
          </div>
        </template>
        <template v-else>
          <router-link to="/">Home</router-link>
          <router-link to="/about">About</router-link>
          <router-link to="/login">Login</router-link>
          <router-link class="nav-signup" to="/signup">Signup</router-link>
        </template>
      </div>
    </nav>
  </header>
</template>

<script>
import { isPreview } from '../config'
import { authRoute } from '../auth-navigation'

export default {
  data() {
    return {
      menuOpen: false,
      accountOpen: false,
      preview: isPreview,
      loggedIn: isPreview || !!localStorage.getItem('jwt')
    }
  },
  watch: {
    $route() {
      this.menuOpen = false
      this.accountOpen = false
      this.syncSession()
    }
  },
  mounted() {
    window.addEventListener('storage', this.syncSession)
    document.addEventListener('pointerdown', this.closeOutside)
    document.addEventListener('focusin', this.closeOutside)
  },
  beforeUnmount() {
    window.removeEventListener('storage', this.syncSession)
    document.removeEventListener('pointerdown', this.closeOutside)
    document.removeEventListener('focusin', this.closeOutside)
  },
  methods: {
    syncSession() {
      this.loggedIn = isPreview || !!localStorage.getItem('jwt')
      if (!this.loggedIn && ['/contact', '/reachout', '/account'].includes(this.$route.path)) {
        this.$router.replace(authRoute('/login', this.$route.fullPath))
      }
    },
    closeOutside(event) {
      if (!this.$refs.accountMenu?.contains(event.target)) this.accountOpen = false
    },
    closeMenus() {
      if (this.accountOpen) {
        this.accountOpen = false
        this.$refs.accountToggle.focus()
      } else {
        this.menuOpen = false
      }
    }
  }
}
</script>

<style scoped>
.account-menu {
  position: relative;
}
.account-toggle {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  border: 0;
  border-radius: 6px;
  padding: 10px 14px;
  min-height: 44px;
  background: transparent;
  color: var(--muted);
  font-size: 0.94rem;
  font-weight: 550;
  cursor: pointer;
}
.account-toggle:hover,
.account-toggle.active,
.account-toggle[aria-expanded='true'] {
  background: #ecefe6;
  color: var(--ink);
}
.account-links {
  position: absolute;
  right: 0;
  top: calc(100% + 8px);
  z-index: 10;
  width: 210px;
  display: grid;
  padding: 8px;
  background: white;
  border: 1px solid var(--line);
  border-radius: 10px;
  box-shadow: 0 12px 30px #20392d18;
}
@media (max-width: 700px) {
  .account-toggle {
    width: 100%;
    padding: 12px;
  }
  .account-links {
    position: static;
    width: auto;
    margin: 4px 0;
    box-shadow: none;
  }
}
</style>

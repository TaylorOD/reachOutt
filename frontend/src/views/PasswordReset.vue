<template>
  <div class="section-container"><main class="container reset-form">
    <h1 class="h2">{{ resetting ? 'Choose a new password' : 'Reset your password' }}</h1>
    <p v-if="message" role="status">{{ message }}</p>
    <p v-for="error in errors" :key="error" class="text-danger" role="alert">{{ error }}</p>
    <form v-if="!done" @submit.prevent="submit">
      <template v-if="resetting">
        <p>Use at least 12 characters.</p>
        <div class="form-group"><label for="new-password">New password</label>
          <input id="new-password" v-model="password" class="form-control" type="password" autocomplete="new-password" minlength="12" required></div>
        <div class="form-group"><label for="confirm-password">Confirm password</label>
          <input id="confirm-password" v-model="confirmation" class="form-control" type="password" autocomplete="new-password" minlength="12" required></div>
      </template>
      <div v-else class="form-group"><label for="reset-email">Email</label>
        <input id="reset-email" v-model="email" class="form-control" type="email" autocomplete="email" required></div>
      <button class="btn btn-primary" :disabled="saving">{{ saving ? 'Please wait...' : resetting ? 'Save password' : 'Send reset link' }}</button>
    </form>
    <p><router-link to="/login">Back to login</router-link></p>
    <p v-if="resetting"><router-link to="/forgot-password">Request another link</router-link></p>
  </main></div>
</template>
<script>
import axios from 'axios'
export default {
  data() { return { email: '', password: '', confirmation: '', token: '', saving: false, done: false, message: '', errors: [] } },
  computed: { resetting() { return this.$route.path === '/reset-password' } },
  watch: { '$route.path'() { this.done = false; this.message = ''; this.errors = []; this.captureToken() } },
  mounted() { this.captureToken() },
  methods: {
    captureToken() {
      this.token = this.$route.hash.slice(1)
      if (this.token) window.history.replaceState(window.history.state, '', window.location.pathname)
    },
    async submit() {
      if (this.saving) return
      this.saving = true; this.errors = []
      try {
        const response = this.resetting
          ? await axios.patch('/api/password_resets', { token: this.token, password: this.password, password_confirmation: this.confirmation })
          : await axios.post('/api/password_resets', { email: this.email })
        this.message = response.data.message; this.done = true
        if (this.resetting) { localStorage.removeItem('jwt'); delete axios.defaults.headers.common.Authorization }
        this.password = ''; this.confirmation = ''; this.token = ''
      } catch (error) { this.errors = error.response?.data?.errors || ['Unable to reset your password. Please try again.'] }
      finally { this.saving = false }
    }
  }
}
</script>
<style scoped>
.reset-form { max-width: 620px; }
.reset-form p { margin-top: 20px; }
</style>

<template>
  <main class="page container">
    <header class="page-heading">
      <div>
        <p class="eyebrow">Account</p>
        <h1>Password</h1>
        <p>Keep your account secure.</p>
      </div>
    </header>
    <AccountTabs />
    <section class="panel password-panel" aria-label="Password">
      <p v-if="loading" role="status">Loading your account...</p>
      <p v-else-if="error" class="alert alert-danger" role="alert">{{ error }}</p>
      <ChangePassword v-else :email="email" />
    </section>
  </main>
</template>

<script>
import axios from 'axios'
import AccountTabs from '../components/AccountTabs.vue'
import ChangePassword from '../components/ChangePassword.vue'

export default {
  components: { AccountTabs, ChangePassword },
  data() {
    return { email: '', loading: true, error: '' }
  },
  async created() {
    try {
      const { data } = await axios.get('/api/account')
      this.email = data.email
    } catch {
      this.error = 'Could not load your account. Please refresh and try again.'
    } finally {
      this.loading = false
    }
  }
}
</script>

<style scoped>
.password-panel {
  max-width: 620px;
  margin: 0;
}
</style>

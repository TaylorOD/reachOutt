<template>
  <div class="section-container">
    <div class="container">
      <div class="section-container-spacer text-center"><h1 class="h2">05: Account</h1></div>
      <div class="account-form">
        <p v-if="loading" role="status">Loading your account...</p>
        <p v-if="error" class="alert alert-danger" role="alert">{{ error }}</p>
        <p v-if="message" class="alert alert-success" role="status">{{ message }}</p>
        <form v-if="loaded" @submit.prevent="save">
          <div class="form-group">
            <label for="account-first">First name</label
            ><input
              id="account-first"
              class="form-control"
              v-model="profile.first_name"
              autocomplete="given-name"
            />
          </div>
          <div class="form-group">
            <label for="account-last">Last name</label
            ><input
              id="account-last"
              class="form-control"
              v-model="profile.last_name"
              autocomplete="family-name"
            />
          </div>
          <div class="form-group">
            <label for="account-email">Email</label
            ><input
              id="account-email"
              class="form-control"
              type="email"
              v-model="profile.email"
              autocomplete="email"
              required
            />
          </div>
          <div class="form-group">
            <label for="account-phone">Phone number</label
            ><input
              id="account-phone"
              class="form-control"
              type="tel"
              v-model="profile.phone_number"
              autocomplete="tel"
            /><small>Use your country code, like +1. Reminders go to this number.</small>
          </div>
          <div v-if="profile.email.trim().toLowerCase() !== savedEmail" class="form-group">
            <label for="account-password">Current password</label
            ><input
              id="account-password"
              class="form-control"
              type="password"
              v-model="currentPassword"
              autocomplete="current-password"
              required
            />
            <small>Confirm your password to change your email.</small>
          </div>
          <button class="btn btn-primary" :disabled="saving">
            {{ saving ? 'Saving...' : 'Save changes' }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  data() {
    return {
      profile: {},
      savedEmail: '',
      currentPassword: '',
      loading: true,
      loaded: false,
      saving: false,
      error: '',
      message: ''
    }
  },
  async created() {
    try {
      const { data } = await axios.get('/api/account')
      this.profile = data
      this.savedEmail = data.email.toLowerCase()
      this.loaded = true
    } catch {
      this.error = 'Could not load your account. Please refresh and try again.'
    } finally {
      this.loading = false
    }
  },
  methods: {
    async save() {
      if (this.saving) return
      this.saving = true
      this.error = ''
      this.message = ''
      try {
        const { data } = await axios.patch('/api/account', {
          ...this.profile,
          current_password: this.currentPassword
        })
        this.profile = data
        this.savedEmail = data.email.toLowerCase()
        this.currentPassword = ''
        this.message = 'Account saved.'
      } catch (error) {
        this.error =
          error.response?.data?.errors?.join(' ') ||
          'Could not save your account. Please try again.'
      } finally {
        this.saving = false
      }
    }
  }
}
</script>

<style scoped>
.account-form {
  max-width: 620px;
  margin: 0 auto;
}
</style>

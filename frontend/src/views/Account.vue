<template>
  <main class="page account-page">
    <div class="container">
      <header class="page-heading">
        <div>
          <p class="eyebrow">Your details</p>
          <h1>Account</h1>
          <p>Manage your profile, reminder email and password.</p>
        </div>
      </header>
      <div class="settings-layout">
        <section class="account-form panel" aria-labelledby="profile-title">
          <h2 id="profile-title">Your profile</h2>
          <p v-if="loading" role="status">Loading your account...</p>
          <p v-if="error" class="alert alert-danger" role="alert">{{ error }}</p>
          <p v-if="message" class="alert alert-success" role="status">{{ message }}</p>
          <form class="form-stack" v-if="loaded" @submit.prevent="save">
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
              <label for="account-phone">Phone number <span class="optional">Optional</span></label
              ><input
                id="account-phone"
                aria-label="Phone number"
                class="form-control"
                type="tel"
                v-model="profile.phone_number"
                autocomplete="tel"
              /><small>Use your country code, like +1.</small>
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
        </section>
        <aside class="settings-help">
          <section class="panel" aria-labelledby="reminder-email-title">
            <h2 id="reminder-email-title">Your reminder email</h2>
            <template v-if="loaded"
              ><p>
                Reminders arrive at <strong class="saved-email">{{ savedEmail }}</strong
                >.
              </p>
              <p>
                We send them to you, never to your contacts. To use another email, update your
                profile and confirm your current password.
              </p></template
            >
            <p v-else>Your account email is where your reminders arrive.</p>
            <router-link to="/reachout">Manage your reminders</router-link>
          </section>
          <section class="panel" aria-labelledby="account-password-title">
            <h2 id="account-password-title">Password</h2>
            <p>Need a new password? Request a reset link using your account email.</p>
            <router-link class="btn btn-default" to="/forgot-password"
              >Reset your password</router-link
            >
          </section>
        </aside>
      </div>
    </div>
  </main>
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
  min-width: 0;
  margin: 0;
}
.settings-layout {
  display: grid;
  grid-template-columns: minmax(0, 1.2fr) minmax(0, 1fr);
  gap: 32px;
  align-items: start;
}
.account-form h2 {
  margin-bottom: 24px;
}
.settings-help {
  display: grid;
  gap: 24px;
}
.settings-help .panel {
  display: grid;
  gap: 16px;
}
.settings-help p {
  color: var(--muted);
}
.saved-email {
  overflow-wrap: anywhere;
  color: var(--ink);
}
@media (max-width: 800px) {
  .settings-layout {
    grid-template-columns: 1fr;
  }
}
</style>

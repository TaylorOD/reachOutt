<template>
  <div>
    <p>Use at least 12 characters. Changing your password signs you out on every device.</p>
    <form class="form-stack password-form" @submit.prevent="save">
      <p v-if="error" ref="errorMessage" class="alert alert-danger" role="alert" tabindex="-1">
        {{ error }}
      </p>
      <input type="hidden" name="username" autocomplete="username" :value="email" />
      <label
        >Current password
        <input
          :type="showPasswords ? 'text' : 'password'"
          v-model="currentPassword"
          autocomplete="current-password"
          required
        />
      </label>
      <label
        >New password
        <input
          :type="showPasswords ? 'text' : 'password'"
          v-model="password"
          autocomplete="new-password"
          minlength="12"
          required
        />
      </label>
      <label
        >Confirm new password
        <input
          :type="showPasswords ? 'text' : 'password'"
          v-model="confirmation"
          autocomplete="new-password"
          minlength="12"
          required
        />
      </label>
      <label class="password-visibility">
        <input type="checkbox" v-model="showPasswords" /> Show passwords
      </label>
      <button class="btn btn-primary" :disabled="saving">
        {{ saving ? 'Changing password...' : 'Change password' }}
      </button>
    </form>
    <p class="password-reset-link">
      Forgot your current password?
      <router-link to="/forgot-password">Reset your password</router-link>
    </p>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  props: { email: { type: String, required: true } },
  data() {
    return {
      currentPassword: '',
      password: '',
      confirmation: '',
      showPasswords: false,
      saving: false,
      error: ''
    }
  },
  methods: {
    async save() {
      if (this.saving) return
      this.error = ''
      if (this.password !== this.confirmation) {
        this.error = 'Your new passwords do not match.'
        await this.$nextTick()
        this.$refs.errorMessage.focus()
        return
      }
      this.saving = true
      try {
        await axios.patch('/api/account/password', {
          current_password: this.currentPassword,
          password: this.password,
          password_confirmation: this.confirmation
        })
        this.currentPassword = ''
        this.password = ''
        this.confirmation = ''
        localStorage.removeItem('jwt')
        delete axios.defaults.headers.common.Authorization
        await this.$router.replace({
          path: '/login',
          query: { passwordChanged: '1', returnTo: '/account' }
        })
      } catch (error) {
        this.error =
          error.response?.data?.errors?.join(' ') ||
          'Could not change your password. Please try again.'
        await this.$nextTick()
        this.$refs.errorMessage?.focus()
      } finally {
        this.saving = false
      }
    }
  }
}
</script>

<style scoped>
.password-form {
  margin-top: 24px;
}
.password-visibility {
  display: flex;
  align-items: center;
  gap: 10px;
}
.password-visibility input {
  width: 18px;
  min-height: 18px;
  height: 18px;
  accent-color: var(--accent);
}
.password-reset-link {
  margin-top: 24px;
}
</style>

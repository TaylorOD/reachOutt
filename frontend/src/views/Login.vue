<template>
  <main class="page auth-page container">
    <section class="panel auth-panel">
      <p class="eyebrow">Welcome back</p>
      <h1>Good to see you.</h1>
      <p class="muted">Log in and pick up where you left off.</p>
      <p v-if="$route.query.passwordChanged === '1'" class="alert alert-success" role="status">
        Password changed. Log in with your new password.
      </p>
      <form class="form-stack" @submit.prevent="submit">
        <p v-for="error in errors" :key="error" class="alert alert-danger" role="alert">
          {{ error }}
        </p>
        <label
          >Email<input
            type="email"
            v-model="email"
            aria-label="email"
            autocomplete="email"
            required
        /></label>
        <label
          >Password<input
            type="password"
            v-model="password"
            aria-label="password"
            autocomplete="current-password"
            required
        /></label>
        <button class="btn btn-primary" aria-label="Submit">Log in</button>
      </form>
      <div class="auth-links">
        <router-link to="/forgot-password">Forgot your password?</router-link>
        <p>
          New here?
          <router-link :to="authRoute('/signup', $route.query.returnTo)"
            >Create an account</router-link
          >
        </p>
      </div>
    </section>
  </main>
</template>

<script>
import axios from 'axios'
import { authRoute, loginDestination } from '../auth-navigation'

export default {
  data() {
    return {
      email: '',
      password: '',
      errors: []
    }
  },
  methods: {
    authRoute,
    submit() {
      const params = {
        email: this.email,
        password: this.password
      }
      axios
        .post('/api/sessions', params)
        .then((response) => {
          axios.defaults.headers.common['Authorization'] = 'Bearer ' + response.data.jwt
          localStorage.setItem('jwt', response.data.jwt)
          this.$router.replace(loginDestination(this.$route.query.returnTo))
        })
        .catch((error) => {
          this.errors = ['Invalid email or password.']
          this.email = ''
          this.password = ''
        })
    }
  }
}
</script>

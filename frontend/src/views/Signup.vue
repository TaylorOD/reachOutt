<template>
  <main class="page auth-page container">
    <section class="panel auth-panel">
      <p class="eyebrow">Stay a little closer</p>
      <h1>Make time for your people.</h1>
      <p class="muted">Create your account to start keeping in touch.</p>
      <form class="form-stack" @submit.prevent="submit">
        <p v-for="error in errors" :key="error" class="alert alert-danger" role="alert">
          {{ error }}
        </p>
        <div class="form-row">
          <label
            >First name<input
              v-model="first_name"
              aria-label="first name"
              autocomplete="given-name" /></label
          ><label
            >Last name<input v-model="last_name" aria-label="last name" autocomplete="family-name"
          /></label>
        </div>
        <label
          >Email<input
            type="email"
            v-model="email"
            aria-label="email"
            autocomplete="email"
            required
        /></label>
        <label
          >Phone number <span class="optional">Optional</span
          ><input type="tel" v-model="phone_number" aria-label="phone number" autocomplete="tel"
        /></label>
        <label
          >Password<input
            type="password"
            v-model="password"
            aria-label="password"
            autocomplete="new-password"
            required
        /></label>
        <label
          >Confirm password<input
            type="password"
            v-model="passwordConfirmation"
            aria-label="passwordConfirmation"
            autocomplete="new-password"
            required
        /></label>
        <button class="btn btn-primary" aria-label="Submit">Create account</button>
      </form>
      <p class="auth-links">
        Already have an account? <router-link to="/login">Log in</router-link>
      </p>
    </section>
  </main>
</template>

<script>
import axios from 'axios'

export default {
  data() {
    return {
      first_name: '',
      last_name: '',
      phone_number: '',
      email: '',
      password: '',
      passwordConfirmation: '',
      errors: []
    }
  },
  methods: {
    submit() {
      const params = {
        first_name: this.first_name,
        last_name: this.last_name,
        phone_number: this.phone_number,
        email: this.email,
        password: this.password,
        password_confirmation: this.passwordConfirmation
      }
      axios
        .post('/api/users', params)
        .then((response) => {
          this.$router.push('/login')
        })
        .catch((error) => {
          this.errors = error.response?.data?.errors || ['Could not sign up. Please try again.']
        })
    }
  }
}
</script>

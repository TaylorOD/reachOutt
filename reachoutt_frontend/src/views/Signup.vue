<template>
  <div class="signup">
    <div class="section-container">
      <div class="container">

        <div class="col-sm-8 col-sm-offset-2 section-container-spacer">
          <div class="text-center">
            <h1 class="h2">07 : Signup</h1>
          </div>
        </div>
            
        <form v-on:submit.prevent="submit()">
          <h1>Signup</h1>
          <ul>
            <li class="text-danger" v-for="error in errors">{{ error }}</li>
          </ul>
          <div class="form-group">
            <label>First Name:</label> 
            <input type="text" class="form-control" v-model="first_name">
          </div>
          <div class="form-group">
            <label>Last Name:</label> 
            <input type="text" class="form-control" v-model="last_name">
          </div>
          <div class="form-group">
            <label>Email:</label>
            <input type="email" class="form-control" v-model="email">
          </div>
          <div class="form-group">
            <label>Password:</label>
            <input type="password" class="form-control" v-model="password">
          </div>
          <div class="form-group">
            <label>Password confirmation:</label>
            <input type="password" class="form-control" v-model="passwordConfirmation">
          </div>
          <input type="submit" class="btn btn-primary" value="Submit">
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
export default {
  data: function () {
    return {
      first_name: "",
      last_name: "",
      email: "",
      password: "",
      passwordConfirmation: "",
      errors: [],
    };
  },
  methods: {
    submit: function () {
      var params = {
        first_name: this.first_name,
        last_name: this.last_name,
        email: this.email,
        password: this.password,
        password_confirmation: this.passwordConfirmation,
      };
      axios
        .post("/api/users", params)
        .then((response) => {
          this.$router.push("/login");
        })
        .catch((error) => {
          this.errors = error.response.data.errors;
        });
    },
  },
};
</script>
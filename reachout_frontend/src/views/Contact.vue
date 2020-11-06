<template>
  <div class="contacts-index">
    <h1>All Contacts</h1>
    <div v-for="contact in contacts">
      <p>Phone Number: {{ contact.phone_number }}</p>
      <p>First Name: {{ contact.first_name }}</p>
      <p>Last Name: {{ contact.last_name }}</p>
      -
    </div>
  </div>
</template>

<script>
import axios from "axios";
export default {
  data: function() {
    return {
      contacts: [],
    };
  },
  created: function() {
    axios.get("/api/contacts").then(response => {
      console.log("contacts index", response);
      this.contacts = response.data;
    });
  },
  methods: {},
};
</script>
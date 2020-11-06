<template>
  <div class="contacts">
    <h1>New Contact</h1>

    <div>
      Phone Number: <input type="text" v-model="newContactPhoneNumber" />
      First Name: <input type="text" v-model="newContactFirstName" />
      Last Name: <input type="text" v-model="newContactLastName" />
      <button v-on:click="createContact()">Create Contact</button>
    </div>

    <h1>Contacts</h1>
    <div v-for="contact in contacts">
      <p>Phone Number: {{ contact.phone_number }}</p>
      <p>First Name: {{ contact.first_name }}</p>
      <p>Last Name: {{ contact.last_name }}</p>
      -
    </div>
  </div>
</template>

<style>
</style>

<script>
import axios from "axios";
export default {
  data: function() {
    return {
      contacts: [],
      newContactPhoneNumber: "",
      newContactFirstName: "",
      newContactLastName: "",

    };
  },
  created: function() {
    axios.get("/api/contacts").then(response => {
      console.log("contacts index", response);
      this.contacts = response.data;
    });
  },
  methods: {
    createContact: function() {
      var params = {
        phone_number: this.newContactPhoneNumber,
        first_name: this.newContactFirstName,
        last_name: this.newContactLastName,
      };
      axios
        .post("/api/contacts", params)
        .then(response => {
          console.log("contacts create", response);
          this.contacts.push(response.data);

          this.newContactPhoneNumber = "";
          this.newContactFirstName = "";
          this.newContactLastName = "";
        })
        .catch(error => {
          console.log("contacts create error", error.response);
        });
    }
  },  
}
</script>
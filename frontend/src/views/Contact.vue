<template>
  <div class="contacts">
    <div class="section-container">
      <div class="container">
        <!-- Title Div -->
        <div class="col-sm-8 col-sm-offset-2 section-container-spacer">
          <div class="text-center">
            <h1 class="h2">02 : Contacts</h1>
            <h3>View, update, or create a new contact here</h3>
          </div>
        </div>

        <!-- New Contact Div -->
        <div class="text-center section-container-spacer">
          <h2>New Contact</h2>
        </div>

        <form v-on:submit.prevent="createContact">
          <!-- Success message -->
          <div v-if="createdAlert" class="alert alert-success alert-dismissible text-center" role="alert">
            <strong>New Contact Successfully Created!</strong>
            <button type="button" class="close" data-dismiss="alert" aria-label="Close" @click="dismissAlert()">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>

          <!-- Error message -->
          <div v-if="errorMessage" class="alert alert-danger alert-dismissible text-center" role="alert">
            <strong>Error: {{ errorMessage }}</strong>
            <button type="button" class="close" data-dismiss="alert" aria-label="Close" @click="dismissAlert()">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>

          <div class="text-center mb-8">
            First Name: <input type="text" v-model="newContactFirstName" />
            Last Name: <input type="text" v-model="newContactLastName" />
            Phone Number: <input type="text" v-model="newContactPhoneNumber" />
          </div>

          <div class="text-center">
            <button type="submit" class="btn btn-primary btn-sm mb-8">Create Contact</button>
          </div>
        </form>
      </div>

      <!-- Edit Contact Div-->
      <div class="col-md-12">
        <div id="myCarousel" class="carousel slide projects-carousel">
          <div class="carousel-inner">
            <div class="item active">
              <div class="row">
                <div class="text-center section-container-spacer">
                  <h2>Existing Contacts</h2>
                </div>

                <div v-for="(contact, index) in contacts" class="col-sm-4" style="height: 400px">
                  <!-- Image behind Contacts -->
                  <img :src="`/assets/images/work0${index % 7 + 1}-hover.jpg`" alt="" class="img-responsive">
                  
                  <!-- Contact Cards -->
                  <div class="card-container card-container-lg">
                    <h4>Contact Name:</h4>
                    <h3>{{ contact.first_name }} {{ contact.last_name }}</h3>
                    <p>Phone Number: {{ contact.phone_number }}</p>

                    <a class="btn btn-default" v-on:click="showContact(contact)">
                      <p>Edit Contact</p>
                    </a>
                  </div>

                  <!-- Modal to edit contacts -->
                  <dialog id="contact-details">
                    <form method="dialog">
                      <h1>Contact info</h1>                    
                      <p>First Name: <input v-model="currentContact.first_name"></p>
                      <p>Last Name: <input v-model="currentContact.last_name"></p>
                      <p>Phone Number: <input type="text" v-model="currentContact.phone_number"></p>
                      <button class="btn btn-default btn-sm" v-on:click="updateContact(currentContact)">Update</button>
                      <button class="btn btn-default btn-sm" v-on:click="destroyContact(currentContact)">Destroy</button>
                      <button class="btn btn-default btn-sm">Close</button>
                    </form>
                  </dialog>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style>
</style>
<script>
  import axios from 'axios';

  export default {
    data() {
      return {
        contacts: [],
        newContactFirstName: '',
        newContactLastName: '',
        newContactPhoneNumber: '',
        currentContact: {},
        createdAlert: false,
        errorMessage: '',
      };
    },
    created() {
      this.indexContacts();
    },
    methods: {
      async indexContacts() {
        try {
          const response = await axios.get('/api/contacts');
          this.contacts = response.data;
        } catch (error) {
          this.errorMessage = 'Failed to load contacts.';
        }
      },
      async createContact() {
        // Validation
        if (!this.newContactFirstName || this.newContactFirstName.length < 1) {
          this.errorMessage = 'First name is required and must be at least 1 character long.';
          return;
        }
        if (!this.newContactLastName || this.newContactLastName.length < 1) {
          this.errorMessage = 'Last name is required and must be at least 1 character long.';
          return;
        }
        const phoneNumberPattern = /^(\+\d{1,2}\s?)?1?\-?\.?\s?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/;
        if (!this.newContactPhoneNumber || !phoneNumberPattern.test(this.newContactPhoneNumber)) {
          this.errorMessage = 'Phone number is required and must be a valid format.';
          return;
        }
        // If validation passes, clear any previous error message
        this.errorMessage = '';
        try {
          const response = await axios.post('/api/contacts', {
            first_name: this.newContactFirstName,
            last_name: this.newContactLastName,
            phone_number: this.newContactPhoneNumber,
          });
          this.contacts.unshift(response.data);
          this.newContactFirstName = '';
          this.newContactLastName = '';
          this.newContactPhoneNumber = '';
          this.createdAlert = true;
        } catch (error) {
          this.errorMessage = 'Failed to create contact.';
        }
      },
      showContact(contact) {
        this.currentContact = contact;
        document.querySelector('#contact-details').showModal();
      },
      async updateContact(contact) {
        const params = {
          first_name: contact.first_name,
          last_name: contact.last_name,
          phone_number: contact.phone_number,
        };
        try {
          await axios.patch(`/api/contacts/${contact.id}`, params);
        } catch (error) {
          this.errorMessage = 'Failed to update contact.';
        }
      },
      async destroyContact(contact) {
        try {
          await axios.delete(`/api/contacts/${contact.id}`);
          const index = this.contacts.indexOf(contact);
          this.contacts.splice(index, 1);
        } catch (error) {
          this.errorMessage = 'Failed to delete contact.';
        }
      },
      dismissAlert() {
        this.createdAlert = false;
      },
    },
  };
</script>

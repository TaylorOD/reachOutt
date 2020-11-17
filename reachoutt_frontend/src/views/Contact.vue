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

    <!-- Bootstrap alert Code for new Reachout -->
    <div v-if="createdAlert === true" class="alert alert-warning alert-dismissible text-center" role="alert">
      <strong>New Contact Successfully Created!</strong>
      <button type="button" class="close" data-dismiss="alert" aria-label="Close" @click="dismissAlert()">
        <span aria-hidden="true">&times;</span>
      </button>
    </div>

    <div class="text-center">
        First Name: <input type="text" v-model="newContactFirstName" />
        Last Name: <input type="text" v-model="newContactLastName" />
        Phone Number: <input type="text" v-model="newContactPhoneNumber" />
      </div>

      <br>
      <div class="text-center">
        <button class="btn btn-primary btn-sm" v-on:click="createContact()">Create Contact</button>
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
                      <img :src="`/assets/images/work0${index % 6 + 1}-hover.jpg`" alt="" class="img-responsive">
                      
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
                            <p>First Name: <input v-model="currentContact.first_name"></input></p>
                            <p>Last Name: <input v-model="currentContact.last_name"></input></p>
                            <p>Phone Numer: <input type="text" v-model="currentContact.phone_number"></input></p>
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
     </div>
    </div>
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
      newContactFirstName: "",
      newContactLastName: "",
      newContactPhoneNumber: "",
      currentContact: {},
      createdAlert: false
    };
  },
  created: function() {
    this.indexContacts()
  },
  methods: {
    indexContacts: function() {
      axios.get("/api/contacts").then(response => {
        console.log("contacts index:", response)
        this.contacts = response.data
      });
    },
    createContact: function() {
      var params = {
        first_name: this.newContactFirstName,
        last_name: this.newContactLastName,
        phone_number: this.newContactPhoneNumber,
      };
      axios
        .post("/api/contacts", params)
        .then(response => {
          console.log("contacts create", response);
          this.contacts.push(response.data);

          this.newContactFirstName = "";
          this.newContactLastName = "";
          this.newContactPhoneNumber = "";
          this.createdAlert = true
        })
        .catch(error => {
          console.log("Not Successful - contact could not be created", error.response);
        });
    },
    showContact: function (contact) {
        this.currentContact = contact
        document.querySelector("#contact-details").showModal();
    },
    updateContact: function (contact) {
      var params = {
        first_name: contact.first_name,
        last_name: contact.last_name,
        phone_number: contact.phone_number,
      }
      axios
        .patch(`/api/contacts/${contact.id}`, params)
        .then(response => {
          console.log("Success - contact updated", response.data)
        })
        .catch(error => console.log("Not Successful - contact could not be updated", error.response))
    },
    destroyContact: function (contact) {
      console.log(contact)
        axios
          .delete(`/api/contacts/${contact.id}`)
          .then(response => {
            console.log("Success - contact destroyed", response.data)
            // remove this contact from this.contacts / you dont have to reload page
            var index = this.contacts.indexOf(contact);
            this.contacts.splice(index, 1);
          })
          .catch(error => console.log("Not Successful - contact could not be destroyed", error.response))
    },
    dismissAlert() {
      this.createdAlert = false
    }
  },
}

</script>
<template>
  <div class="contacts">
    <div class="section-container">
      <div class="container">
        <div class="col-sm-8 col-sm-offset-2 section-container-spacer">
          <div class="text-center">
            <h1 class="h2">02 : Contacts</h1>
            <h3>View, update, or create a new contact here</h3>
          </div>
        </div>

    <div class="text-center">
      <h2>New Contact</h2>
    </div>
   <div class="text-center">
      Phone Number: <input type="text" v-model="newContactPhoneNumber" />
      First Name: <input type="text" v-model="newContactFirstName" />
      Last Name: <input type="text" v-model="newContactLastName" />
    </div>
    <div class="text-center">
      <button class="btn btn-primary btn-sm" v-on:click="createContact()">Create Contact</button>
    </div>

        <div class="col-md-12">

      <div id="myCarousel" class="carousel slide projects-carousel">
        <div class="carousel-inner">
            <div class="item active">
                <div class="row">
                    <div class="text-center">
                    <h2>Existing Contacts</h2>
                    </div>
                    <div v-for="(contact, index) in contacts" class="col-sm-4" style="height: 400px">
                    

                      <!-- Image behind Contacts -->
                      <img :src="`/assets/images/work0${index % 4 + 1}-hover.jpg`" alt="" class="img-responsive">
                      
                      <!-- Contact Cards -->
                      <div class="card-container card-container-lg">
                        <h4>Contact Name:</h4>
                        <h3>{{ contact.first_name }} {{ contact.last_name }}</h3>
                        <p>Phone Number: {{ contact.phone_number }}</p>
                        <a class="btn btn-default" v-on:click="showContact(currentContact)">
                          <p>Edit Contact</p>
                        </a>
                      </div>

                      <!-- Moduel to edit contacts -->
                      <dialog id="contact-details">
                          <form method="dialog">
                            <h1>Contact info</h1>
                            <p>Phone Numer: <input type="text" v-model="currentContact.phone_number"></input></p>
                            <p>First Name: <input v-model="currentContact.first_name"></input></p>
                            <p>Last Name: <input v-model="currentContact.last_name"></input></p>
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
      newContactPhoneNumber: "",
      newContactFirstName: "",
      newContactLastName: "",
      currentContact: {},
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
    },
    showContact: function (contact) {
        this.currentContact = contact
        document.querySelector("#contact-details").showModal();
    },
    updateContact: function (contact) {
      var params = {
        phone_number: contact.phone_number,
        first_name: contact.first_name,
        last_name: contact.last_name,
      }
      axios
        .patch(`/api/contacts/${contact.id}`, params)
        .then(response => {
          console.log("Success", response.data)
        })
        .catch(error => console.log(error.response))
    },
    destroyContact: function (contact) {
        axios
          .delete(`/api/contacts/${contact.id}`)
          .then(response => {
            console.log("Success - contact destroyed", response.data)
          })
          .catch(error => console.log(error.response))
          // remove this contact from this.contacts / you dont have to reload page
        var index = this.contacts.indexOf(contacts);
        this.contacts.splice(index, 1);
    },
  },
}

</script>
<template>
  <div class="contacts">

    <div class="section-container">
  <div class="container">
    <div class="row">
      
      <div class="col-sm-8 col-sm-offset-2 section-container-spacer">
        <div class="text-center">
          <h1 class="h2">02 : Contacts</h1>
          <p>Nulla facilisi. Vivamus vestibulum, elit in scelerisque ultricies, nisl nunc pulvinar ligula, id sodales arcu sapien in nisi. Quisque libero enim, mattis non augue posuere, venenatis dapibus urna.</p>
        </div>
      </div>

      <div class="col-md-12">
     
      <div id="myCarousel" class="carousel slide projects-carousel">
        <!-- Carousel items -->
        <div class="carousel-inner">
            <div class="item active">
                <div class="row">
                    <div v-for="contact in contacts" class="col-sm-4">

                      <a href="./work.html" title="" class="black-image-project-hover">
                        <img src="/assets/images/work01-hover.jpg" alt="" class="img-responsive">
                      </a>
                      <div class="card-container card-container-lg">
                        <h4>001/006</h4>
                        <h3>Fringilla sit amet</h3>
                        <p>Nulla facilisi. Vivamus vestibulum, elit in scelerisque ultricies.</p>
                        <a href="./work.html" title="" class="btn btn-default">Discover</a>
                      </div>
                    </div>
                    
                </div>
                <!--/row-->
            </div>
            <!--/item-->

            
            <!--/item-->
        </div>
        <!--/carousel-inner--> 
        <a class="left carousel-control" href="#myCarousel" data-slide="prev">‹</a>

        <a class="right carousel-control" href="#myCarousel" data-slide="next">›</a>
     </div>



    <!--/myCarousel-->
    </div>



    </div>
  </div>
</div>
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
      <a v-on:click="showContact(currentContact)">
        <h3>Edit Contact</h3>
      </a> 
    </div>


    <dialog id="contact-details">
        <form method="dialog">
          <h1>Contact info</h1>
          <p>Phone Numer: <input type="text" v-model="currentContact.phone_number"></p>
          <p>First Name: <input v-model="currentContact.first_name"></input></p>
          <p>Last Name: <input v-model="currentContact.last_name"></input></p>
          <button v-on:click="updateContact(currentContact)">Update</button>
          <button v-on:click="destroyContact(currentContact)">Destroy</button>
          <button>Close</button>
        </form>
    </dialog>

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
        var index = this.contacts.indexOf(product);
        this.contacts.splice(index, 1);
    },
  },
}

</script>
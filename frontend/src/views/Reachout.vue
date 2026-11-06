<template>
  <div class="reachout">
    <p v-if="errorMessage" class="alert alert-danger" role="alert">{{ errorMessage }}</p>
    <div class="section-container">
      <div class="container">
        <!-- Title Div -->
        <div class="col-sm-8 col-sm-offset-2 section-container-spacer">
          <div class="text-center">
            <h1 class="h2">03 : Reachouts</h1>
            <h3>View, update, or create a new reachout here</h3>
          </div>
        </div>

        <!-- New Reachout Div -->
        <div class="text-center section-container-spacer">
          <h2>New Reachout</h2>
        </div>
        
        <!-- Bootstrap alert Code for new Reachout -->
        <div v-if="createdAlert === true" class="alert alert-warning alert-dismissible text-center" role="alert">
          <strong>New Reachout Successfully Created!</strong>
          <button type="button" class="close" data-dismiss="alert" aria-label="Close" @click="dismissAlert()">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>

        <div class="text-center">          
          <!-- Frequency selector drop down form -->
          Frequency: 
          <select class="text-center" v-model="newReachoutFrequency" aria-label="New Frequency">
            <option value="" selected disabled>Select Frequency</option>
            <option v-for="reachoutFrequency in reachoutFrequencys" :value="reachoutFrequency.value" :key="reachoutFrequency.id">{{ reachoutFrequency.name }}</option>
          </select>

          <!-- Contact selector drop down form -->   
          Contact Name: 
          <select class="text-center" v-model="newReachoutContactID" aria-label="New ContactID">
            <option value="" selected disabled>Select Contact</option>
            <option v-for="contact in contacts" :value="contact.id" :key="contact.id">{{ contact.first_name }} {{ contact.last_name }}</option>
          </select>       

          Topic: 
          <select class="text-center" v-model="newReachoutTopic" aria-label="New Topic">
            <option value="" selected disabled>Select Topic</option>
            <option value="Jokes">Jokes</option>
            <option value="News">News</option>
            <option value="Sports">Sports</option>
          </select> 

          Start Date: <input type="date" id="start" v-model="newReachoutStartDate" aria-label="New StartDate">

          <!-- Will re add these if needed params later -->
          <!-- Last Reachout Sent: <input type="text" v-model="newReachoutLastReachoutSent" aria-label="New LastReachoutSent" /> -->
          <!-- Datetime: <input type="text" v-model="newReachoutDatetime" aria-label="New Datetime" /> -->
        </div>

        <div class="text-center">
          <button class="btn btn-primary btn-sm" v-on:click="createReachout()">Create Reachout</button>
        </div>
      </div>
      
      <!-- Existing Reachouts Div  -->
      <div class="col-md-12">
        <div id="myCarousel" class="carousel slide projects-carousel">
          <div class="carousel-inner">
            <div class="item active">
              <div class="row">
                <div class="text-center section-container-spacer">
                  <h2>Existing Reachouts</h2>
                </div>

                <div v-for="(reachout, index) in reachouts.filter(item => item.contact)" :key="reachout.id" class="col-sm-4" style="height: 500px">
                  <!-- Image behind Reachouts -->
                  <img :src="`/app/assets/images/work0${index % 7 + 1}-hover.jpg`" alt="" class="img-responsive">
                  <!-- Reachout Cards -->
                  <div class="card-container card-container-lg">
                    <h4>Reachouts:</h4>
                    <p>Status: {{ reachout.enabled ? 'Active' : 'Paused' }}</p>
                    <button class="btn btn-default" :disabled="pendingIds.includes(reachout.id)" @click="toggleReachout(reachout)">{{ reachout.enabled ? 'Pause reminder' : 'Resume reminder' }}</button>

                    <p>Contact Name: {{ reachout.contact.first_name }} {{ reachout.contact.last_name }}</p>
                    
                    <p>Frequency: {{ frequencyToName(reachout.frequency) }}</p>

                    <p v-if="reachout.topic">Topic: {{ reachout.topic }} </p>

                    <p>Start Date: {{ reachout.start_date }}</p>
                    
                    <!-- Will readd these if needed later -->
                    <!-- <p>Datetime: {{ reachout.datetime }}</p> -->
                    <!-- <p>Last Reachout Sent: {{ reachout.last_reachout_sent }}</p> -->

                    <a class="btn btn-default" role="button" tabindex="0" @keydown.enter="showReachout(reachout)" v-on:click="showReachout(reachout)">
                      <p>Edit Reachout</p>
                    </a> 
                  </div>

                  <!-- Modal to edit Reachouts -->
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

                  <dialog id="reachout-details">
                    <form method="dialog">
                      <p v-if="errorMessage" role="alert" class="text-danger">{{ errorMessage }}</p>
                      <h1>Reachout info</h1>
                        <p>Contact Name: {{ currentReachout.contact?.first_name }} {{ currentReachout.contact?.last_name }}</p>
                        <p>Edit contact details on the Contacts page.</p>
                        <br>
                        <br>
                        <!-- <p>Last Reachout Sent: <input v-model="currentReachout.last_reachout_sent" aria-label="Edit last reachout sent"></input></p> -->
                    
                        Frequency:
                        <select class="text-center" v-model="currentReachout.frequency" aria-label="Edit frequency">
                          <option value="" selected disabled>Select Frequency</option>
                          <option v-for="reachoutFrequency in reachoutFrequencys" :value="reachoutFrequency.value" :key="reachoutFrequency.id">{{ reachoutFrequency.name }}</option>
                        </select>
                        <br>
                        <br>

                        Topic: 
                        <select class="text-center" v-model="currentReachout.topic" aria-label="Edit topic">
                          <option value="" selected disabled>Select Topic</option>
                          <option value="Jokes">Jokes</option>
                          <option value="News">News</option>
                          <option value="Sports">Sports</option>
                        </select>
                        <br>
                        <br> 

                        <p>Start Date: {{ currentReachout.start_date }}</p>
                        <!-- <p>Contact ID: <input type="text" v-model="currentReachout.contact_id" aria-label="Edit contact id"></input></p> -->
                        <!-- <p>Datetime:<input v-model="currentReachout.datetime" aria-label="Edit datetime"></input></p> -->
                      <button type="button" class="btn btn-default btn-sm" v-on:click="updateReachout(currentReachout)">Update</button>
                      <button type="button" class="btn btn-default btn-sm" v-on:click="destroyReachout(currentReachout)">Destroy</button>
                      <button class="btn btn-default btn-sm">Close</button>
                    </form>
                  </dialog>
</template>

<style>
</style>

<script>
  import axios from "axios";

  export default {
    data: function() {
      return {
        reachouts: [],
        pendingIds: [],
        reachoutFrequencys: [
          { name: "Daily", id: 1, value: "1d" },
          { name: "Weekly", id: 2, value: "7d" },
          { name: "Bi-Weekly", id: 3, value: "14d" },
          { name: "Monthly", id: 4, value: "30d" },
          { name: "Bi-Monthly", id: 5, value: "60d" },
          { name: "Quarterly", id: 6, value: "90d" },
          { name: "Semi-Annually", id: 7, value: "182.5d" },
          { name: "Annually", id: 8, value: "365d" },
        ],
        contacts: [],
        newReachoutStartDate: "",
        newReachoutLastReachoutSent: "",
        newReachoutFrequency: "",
        newReachoutContactID: "",
        newReachoutDatetime: "",
        newReachoutTopic: "",
        currentReachout: {},
        createdAlert: false,
        errorMessage: "",
      };
    },
    created: function() {
      this.indexContacts();
      

    },
    methods: {
      async toggleReachout(reachout) {
        if (this.pendingIds.includes(reachout.id)) return
        this.pendingIds.push(reachout.id)
        this.errorMessage = ''
        try {
          const response = await axios.patch(`/api/reachouts/${reachout.id}`, { enabled: !reachout.enabled })
          const index = this.reachouts.findIndex(item => item.id === reachout.id)
          if (index !== -1) this.reachouts.splice(index, 1, response.data)
        } catch (error) { this.errorMessage = 'Could not change reminder status. Please try again.' }
        finally { this.pendingIds = this.pendingIds.filter(id => id !== reachout.id) }
      },
      indexReachouts: function() {
        axios.get("/api/reachouts").then(response => {
          this.reachouts = response.data;
        });
      },
      indexContacts: function() {
        axios.get("/api/contacts").then(response => {
          this.contacts = response.data;
          this.indexReachouts();
        });
      },
      createReachout: function() {
        var params = {
          start_date: this.newReachoutStartDate,
          last_reachout_sent: this.newReachoutLastReachoutSent,
          frequency: this.newReachoutFrequency,
          contact_id: this.newReachoutContactID,
          datetime: this.newReachoutDatetime,
          topic: this.newReachoutTopic,
        };
        axios
          .post("/api/reachouts", params)
          .then(response => {
            this.reachouts.push(response.data);


            this.newReachoutStartDate = "";
            this.newReachoutLastReachoutSent = "";
            this.newReachoutFrequency = "";
            this.newReachoutContactID = "";
            this.newReachoutDatetime = "";
            this.newReachoutTopic = "";
            this.createdAlert = true
          })
          .catch(error => {
            this.errorMessage = error.response?.data?.errors?.join(" ") || "Could not create reminder.";
          });
      },
      showReachout: function (reachout) {
        this.errorMessage = "";
        this.currentReachout = { ...reachout }
        document.querySelector("#reachout-details").showModal();
      },
      updateReachout: function (reachout) {
        var params = {
          start_date: reachout.start_date,
          last_reachout_sent: reachout.last_reachout_sent,
          frequency: reachout.frequency,
          datetime: reachout.datetime,
          topic: reachout.topic,
        }
        axios
          .patch(`/api/reachouts/${reachout.id}`, params)
          .then(response => {
            var index = this.reachouts.findIndex(item => item.id === reachout.id);
            if (index !== -1) this.reachouts.splice(index, 1, response.data);
            document.querySelector("#reachout-details").close();
          })
          .catch(error => { this.errorMessage = error.response?.data?.errors?.join(" ") || "Could not save reminder." })
      },
      destroyReachout: function (reachout) {
          axios
            .delete(`/api/reachouts/${reachout.id}`)
            .then(response => {
              // remove this reachout from this.reachouts / you don't have to reload page
              var index = this.reachouts.findIndex(item => item.id === reachout.id);
              if (index !== -1) this.reachouts.splice(index, 1);
              document.querySelector("#reachout-details").close();
            })
            .catch(error => { this.errorMessage = error.response?.data?.errors?.join(" ") || "Could not save reminder." })
      },
      frequencyToName: function (frequency) {
        // refactor this using a loop
        if (frequency === "1d") {
          frequency = "Daily"
        } else if (frequency === "7d") {
          frequency = "Weekly"
        } else if (frequency === "14d") {
          frequency = "Bi-Weekly"
        } else if (frequency === "30d") {
          frequency = "Monthly"
        } else if (frequency === "60d") {
          frequency = "Bi-Monthly"
        } else if (frequency === "90d") {
          frequency = "Quarterly"
        } else if (frequency === "182.5d") {
          frequency = "Semi-Annually"
        } else if (frequency === "365d") {
          frequency = "Annually"
        }

        return frequency
      },
      dismissAlert() {
        this.createdAlert = false
      }
    },
  }
</script>

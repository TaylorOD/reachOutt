<template>
  <div class="reachout">
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
        <div class="text-center">
          <h2>New Reachout</h2>
        </div>

        <div class="text-center">          
          Start Date: <input type="date" id="start" v-model="newReachoutStartDate">

          <!-- Frequency selector drop down form -->
          Frequency: 
          <select class="text-center" v-model="newReachoutFrequency">
            <option value="" selected disabled>Select Frequency</option>
            <option v-for="reachoutFrequency in reachoutFrequencys" :value="reachoutFrequency.value" :key="reachoutFrequency.id">{{ reachoutFrequency.name }}</option>
          </select>

          <!-- Contact selector drop down form -->   
          Contact: 
          <select class="text-center" v-model="newReachoutContactID">
            <option value="" selected disabled>Select Contact</option>
            <option v-for="contactID in contactIDs" :key="reachout.contact_id">{{ reachout.contact_id }}</option>
          </select>          
          
          <!-- Contact: <input type="text" v-model="newReachoutContactID" /> -->


          <!-- Will readd these is needed params later -->
          <!-- Last Reachout Sent: <input type="text" v-model="newReachoutLastReachoutSent" /> -->
          <!-- Datetime: <input type="text" v-model="newReachoutDatetime" /> -->
        </div>
        <br>
        <div class="text-center">
          <button class="btn btn-primary btn-sm" v-on:click="createReachout()">Create Reachout</button>
        </div>

        <!-- Existing Reachouts Div  -->
      <div class="col-md-12">
      <div id="myCarousel" class="carousel slide projects-carousel">
        <div class="carousel-inner">
            <div class="item active">
                <div class="row">

                    <div class="text-center">
                      <h2>Existing Reachouts</h2>
                    </div>
                    <div v-for="(reachout, index) in reachouts" class="col-sm-4" style="height: 500px">

                      <!-- Image behind Reachouts -->
                      <img :src="`/assets/images/work0${index % 6 + 1}-hover.jpg`" alt="" class="img-responsive">
                      
                      <!-- Reachout Cards -->
                      <div class="card-container card-container-lg">
                        <h4>Reachouts:</h4>

                        <p>Start Date: {{ reachout.start_date }}</p>
                        <!-- <p>Last Reachout Sent: {{ reachout.last_reachout_sent }}</p> -->
                        <p>Frequency: {{ reachout.frequency }}</p>
                        
                        <p>Contact: {{ reachout.contact_id }}</p>
                        <!-- <p>Datetime: {{ reachout.datetime }}</p> -->
                        <a class="btn btn-default"  v-on:click="showReachout(reachout)">
                          <p>Edit Reachout</p>
                        </a> 
                      </div>

                      <!-- Modal to edit Reachouts -->
                      <dialog id="reachout-details">
                          <form method="dialog">
                            <h1>Reachout info</h1>
                                <p>Start Date: {{ currentReachout.start_date }}</input></p>
                                <!-- <p>Last Reachout Sent: <input v-model="currentReachout.last_reachout_sent"></input></p> -->
                                Frequency:
                                <select class="text-center" v-model="newReachoutFrequency">
                                  <option value="" selected disabled>Select Frequency</option>
                                  <option v-for="reachoutFrequency in reachoutFrequencys" :value="reachoutFrequency.value" :key="reachoutFrequency.id">{{ reachoutFrequency.name }}</option>
                                </select>

                                Contact: 
                                <select class="text-center" v-model="newReachoutContactID">
                                  <option value="" selected disabled>Select Contact</option>
                                  <option v-for="contactID in contactIDs" :key="reachout.contact_id">{{ reachout.contact_id }}</option>
                                </select>

                                <!-- <p>Contact ID: <input type="text" v-model="currentReachout.contact_id"></input></p> -->
                                <!-- <p>Datetime:<input v-model="currentReachout.datetime"></input></p> -->
                              <button class="btn btn-default btn-sm" v-on:click="updateReachout(currentReachout)">Update</button>
                              <button class="btn btn-default btn-sm" v-on:click="destroyReachout(currentReachout)">Destroy</button>
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
</template>

<style>
</style>

<script>
import axios from "axios";

export default {
  data: function() {
    return {
      reachouts: [],
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
      contactIDs: [],
      newReachoutStartDate: "",
      newReachoutLastReachoutSent: "",
      newReachoutFrequency: "",
      newReachoutContactID: "",
      newReachoutDatetime: "",
      currentReachout: {},
    };
  },
  created: function() {
    this.indexReachouts();

  },
  methods: {
    indexReachouts: function() {
      axios.get("/api/reachouts").then(response => {
        console.log("reachouts index", response);
        this.reachouts = response.data;
      });
    },
    createReachout: function() {
      var params = {
        start_date: this.newReachoutStartDate,
        last_reachout_sent: this.newReachoutLastReachoutSent,
        frequency: this.newReachoutFrequency,
        contact_id: this.newReachoutContactID,
        datetime: this.newReachoutDatetime,
      };
      axios
        .post("/api/reachouts", params)
        .then(response => {
          console.log("Succsess - reachout create", response);
          this.reachouts.push(response.data);

          this.newReachoutStartDate = "";
          this.newReachoutLastReachoutSent = "";
          this.newReachoutFrequency = "";
          this.newReachoutContactID = "";
          this.newReachoutDatetime = ""
        })
        .catch(error => {
          console.log("Not Successful - reachout could not be created", error.response);
        });
    },
    showReachout: function (reachout) {
      this.currentReachout = reachout
      document.querySelector("#reachout-details").showModal();
    },
    updateReachout: function (reachout) {
      var params = {
        start_date: reachout.start_date,
        last_reachout_sent: reachout.last_reachout_sent,
        frequency: reachout.frequency,
        contact_id: reachout.contact_id,
        datetime: reachout.datetime,
      }
      axios
        .patch(`/api/reachouts/${reachout.id}`, params)
        .then(response => {
          console.log("Success - reachout updated", response.data)
        })
        .catch(error => console.log("Not Successful - reachout could not be updated", error.response))
    },
    destroyReachout: function (reachout) {
        axios
          .delete(`/api/reachouts/${reachout.id}`)
          .then(response => {
            console.log("Success - Reachout destroyed", response.data)
            // remove this reachout from this.reachouts / you dont have to reload page
            var index = this.reachouts.indexOf(reachout);
            this.reachouts.splice(index, 1);
          })
          .catch(error => console.log("Not Successful - reachout could not be destroyed", error.response))
    },
  },  
}

</script>
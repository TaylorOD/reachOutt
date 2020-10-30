<template>
  <div class="home">
    <h1>New Reachout</h1>

    <div>
      Start Date: <input type="text" v-model="newReachoutStartDate" />
      Last Reachout Sent: <input type="text" v-model="newReachoutLastReachoutSent" />
      Frequency: <input type="text" v-model="newReachoutFrequency" />
      Contact ID: <input type="text" v-model="newReachoutContactID" />
      Datatime: <input type="text" v-model="newReachoutDatetime" />
      <button v-on:click="createReachout()">Create Reachout</button>
    </div>

    <h2>All Reachouts</h2>
    <div v-for="reachout in reachouts">
      <p>Start Date: {{ reachout.start_date }}</p>
      <p>Last Reachout Sent: {{ reachout.last_reachout_sent }}</p>
      <p>Frequency: {{ reachout.frequency }}</p>
      <p>Contact ID: {{ reachout.contact_id }}</p>
      <p>Datatime: {{ reachout.datetime }}</p>
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
      reachouts: [],
      newReachoutStartDate: "",
      newReachoutLastReachoutSent: "",
      newReachoutFrequency: "",
      newReachoutContactID: "",
      newReachoutDatetime: "",
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
          console.log("reachouts create", response);
          this.reachouts.push(response.data);

          this.newReachoutStartDate = "";
          this.newReachoutLastReachoutSent = "";
          this.newReachoutFrequency = "";
          this.newReachoutContactID = "";
          this.newReachoutDatetime = ""
        })
        .catch(error => {
          console.log("reachouts create error", error.response);
        });
    }
  },  
}

</script>
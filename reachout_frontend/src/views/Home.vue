<template>
  <div class="home">
    <h1>New reachout</h1>
    <div>
      Start Date: <input type="text" v-model="newPhotoName" />
      Last Reachout Sent: <input type="text" v-model="newPhotoWidth" />
      Frequency: <input type="text" v-model="newPhotoHeight" />
      Contact ID: <input type="text" v-model="newPhotoUrl" />
      Datatime: <input type="text" v-model="newPhotoUrl" />
      <button v-on:click="createPhoto()">Create Photo</button>
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
      newReachoutName: "",
      newReachoutWidth: "",
      newReachoutHeight: "",
      newReachoutUrl: "",
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
        name: this.newReachoutName,
        width: this.newReachoutWidth,
        height: this.newReachoutHeight,
        url: this.newReachoutUrl,
      };
      axios
        .post("/api/reachouts", params)
        .then(response => {
          console.log("reachouts create", response);
          this.reachouts.push(response.data);
          this.newReachoutName = "";
          this.newReachoutWidth = "";
          this.newReachoutHeight = "";
          this.newReachoutUrl = "";
        })
        .catch(error => {
          console.log("reachouts create error", error.response);
        });
      }
    },  
  },
};
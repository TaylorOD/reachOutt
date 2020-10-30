<template>
  <div class="home">
    <h2>All Reachouts</h2>
    <div v-for="reachout in reachouts">
      <p>Start Date: {{ reachout.start_date }}</p>
      <!-- <img v-bind:src="reachout.url" v-bind:alt="reachout.name" /> -->
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
  },
};
</script>
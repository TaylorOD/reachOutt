<template>
  <div class="reachout">
    <h1>New Reachout</h1>

    <div>
      Start Date: <input type="text" v-model="newReachoutStartDate" />
      Last Reachout Sent: <input type="text" v-model="newReachoutLastReachoutSent" />
      Frequency: <input type="text" v-model="newReachoutFrequency" />
      Contact ID: <input type="text" v-model="newReachoutContactID" />
      Datatime: <input type="text" v-model="newReachoutDatetime" />
      <button v-on:click="createReachout()">Create Reachout</button>
    </div>

    <h1>Reachouts</h1>
    <div v-for="reachout in reachouts">
      <p>Start Date: {{ reachout.start_date }}</p>
      <p>Last Reachout Sent: {{ reachout.last_reachout_sent }}</p>
      <p>Frequency: {{ reachout.frequency }}</p>
      <p>Contact ID: {{ reachout.contact_id }}</p>
      <p>Datatime: {{ reachout.datetime }}</p>
      <a v-on:click="showReachout(Reachout)">
        <h3>Edit Reachout</h3>
      </a> 
      
    </div>

    <dialog id="reachout-details">
        <form method="dialog">
          <h1>Reachout info</h1>
          <p>Start Date:  <input type="text" v-model="currentReachout.start_date"></p>
          <p>Last Reachout Sent: <input v-model="currentReachout.last_reachout_sent"></input></p>
          <p>Frequency:<input v-model="currentReachout.frequency"></input></p>
          <p>Contact ID:<input v-model="currentReachout.contact_id"></input></p>
          <p>Datatime:<input v-model="currentReachout.datetime"></input></p>

          <button v-on:click="updateReachout(currentReachout)">Update</button>
          <button v-on:click="destroyReachout(currentReachout)">Destroy</button>
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
      reachouts: [],
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
          console.log("Success", response.data)
        })
        .catch(error => console.log(error.response))
    },
    destroyReachout: function (reachout) {
        axios
          .delete(`/api/reachouts/${reachout.id}`)
          .then(response => {
            console.log("Success - reachout destroyed", response.data)
          })
          .catch(error => console.log(error.response))
          // remove this reachout from this.reachouts / you dont have to reload page
        var index = this.reachouts.indexOf(product);
        this.reachouts.splice(index, 1);
    },
  },  
}

</script>
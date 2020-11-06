<template>
  <div class="home">
      <div class="hero-full-container background-image-container white-text-container" style="background-image: url('./assets/images/space.jpg')">
    <div class="container">
      <div class="row">
        <div class="col-xs-12">
          <div class="hero-full-wrapper">
            <div class="text-content">
              <h1>Hello,<br>
                <span id="typed-strings">
                  <span>I'm a family member</span>
                  <span>Friend</span>
                  <span>Someone who misses you</span>
                  <span>Reachout</span>
                </span>
                <span id="typed"></span>
              </h1>
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
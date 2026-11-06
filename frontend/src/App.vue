<template>
  <div id="app">
      <!-- Website Padding -->
      <div id="site-border-left"></div>
      <div id="site-border-right"></div>
      <div id="site-border-top"></div>
      <div id="site-border-bottom"></div>

      <!-- Header Code that is on each page -->
      <header>
        <nav class="navbar  navbar-fixed-top" v-bind:class="{'navbar-inverse': $route.meta.inverse, 'navbar-default': !$route.meta.inverse}">
          <div class="container">
              <button type="button" class="navbar-toggle collapsed" :aria-expanded="menuOpen" aria-controls="navbar-collapse" @click="menuOpen = !menuOpen">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
              </button>

            <!-- Nav bar links that are on each page -->
            <div class="collapse navbar-collapse" :class="{ in: menuOpen }" id="navbar-collapse">
              <ul class="nav navbar-nav ">
                <li><router-link to="/">01: Home</router-link></li>
                <li><router-link to="/about">02: About</router-link></li>
                <li v-if="isLoggedIn()"><router-link to="/contact">03: Contacts</router-link></li>
                <li v-if="isLoggedIn()"><router-link to="/reachout">04: Reachouts</router-link></li>
                <li v-if="!isLoggedIn()"><router-link to="/login">03: Login</router-link></li>
                <li v-if="isLoggedIn()"><router-link to="/account">05: Account</router-link></li>
                <li v-if="isLoggedIn()"><router-link to="/logout">06: Logout</router-link></li>
                <li v-if="!isLoggedIn()"><router-link to="/signup">04: Signup</router-link></li>
              </ul>
            </div> 
          </div>
        </nav>
      </header>
    <!-- Router link files -->
    <router-view/>

    <!-- Footer code that is on each page -->
    <footer v-if="!$route.meta.inverse" class="footer-container text-center">
      <div class="container">
        <div class="row">
          <div class="col-xs-12">
            <p>©ReachOutt</p>
          </div>
        </div>
      </div>
    </footer>

  </div>

</template>


<script>
export default {
  data() { return { menuOpen: false } },
  watch: { '$route'() { this.menuOpen = false } },
  methods: {
    isLoggedIn() { return !!localStorage.getItem('jwt') }
  }
}
</script>

<style>
.text-danger { color: #a61b1b; }
.btn-primary:hover, .btn-primary:focus { color: #fff; background: #000; border-color: #000; }
.navbar-inverse .navbar-nav > li > a { color: #fff; }
dialog { max-width: calc(100vw - 32px); max-height: calc(100vh - 32px); overflow: auto; }
dialog h1 { font-size: 32px; }
@media (max-width: 600px) {
  .home h1 { font-size: 48px; }
}


</style>

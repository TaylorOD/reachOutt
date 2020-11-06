<template>
  <div id="app">
    <div id="nav">
      <div id="site-border-left"></div>
      <div id="site-border-right"></div>
      <div id="site-border-top"></div>
      <div id="site-border-bottom"></div>
      <header>
        <nav class="navbar  navbar-fixed-top navbar-inverse">
          <div class="container">
              <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse" aria-expanded="false">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
              </button>

            <div class="collapse navbar-collapse" id="navbar-collapse">
              <ul class="nav navbar-nav ">
                <li><a href="./" title="">01 : Home</a></li>
                <li><a href="./contact" title="">02 : Contacts</a></li>
                <li><a href="./reachout" title="">03 : Reachouts</a></li>
                <li><a href="./login" title="">04 : Login</a></li>
                <li><a href="./logout" title="">05 : Logout</a></li>
                <li><a href="./signup" title="">06 : Signup</a></li>
              </ul>

            </div> 
          </div>
        </nav>
</header>
      <!-- <router-link to="/">Home</router-link> |
      <router-link to="/contact">Contact</router-link> |
      <router-link to="/signup">Signup</router-link> |
      <router-link to="/login">Login</router-link> |
      <router-link to="/logout">Logout</router-link> -->
    </div>
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
    <router-view/>

    <!-- <div class="hero-full-container background-image-container white-text-container" style="background-image: url('./assets/images/space.jpg')">
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
    </div> -->


  </div>
</template>

<style>

</style>

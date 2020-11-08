<template>
  <div id="app">
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

    <router-view/>
  
  </div>


</template>

<style>

</style>

<template>
  <div class="home">
    <div class="hero-full-container background-image-container white-text-container" style="background-image: url('./assets/images/space.jpg')">
      <div class="container">
        <div class="row">
          <div class="col-xs-12">
            <div class="hero-full-wrapper">
              <!-- Scrolling Text Div -->
              <div class="text-content">
                <h1>Hello,<br>
                  <span id="typed-strings">
                    <span>I'm a family member</span>
                    <span>Friend</span>
                    <span>Someone who misses you</span>
                    <span>ReachOutt</span>
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
 export default{
   mounted: function () {
     type();
     movingBackgroundImage();
   }
 }
</script>
<template>
  <div class="home">
    <div
      class="hero-full-container background-image-container white-text-container"
      :style="{ backgroundImage: `url('${assetPath('assets/images/space.jpg')}')` }"
    >
      <div class="container">
        <div class="row">
          <div class="col-xs-12">
            <div class="hero-full-wrapper">
              <div class="text-content">
                <h1>
                  Hello,<br />
                  <span>{{ greeting }}</span>
                </h1>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { assetPath } from '../config'
export default {
  methods: { assetPath },
  data() {
    return { greeting: "I'm a family member", timer: null }
  },
  mounted() {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return
    const greetings = ["I'm a family member", 'Friend', 'Someone who misses you', 'ReachOutt']
    let index = 0
    this.timer = window.setInterval(() => {
      this.greeting = greetings[++index % greetings.length]
    }, 3000)
  },
  beforeUnmount() {
    window.clearInterval(this.timer)
  }
}
</script>

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
                  <span class="sr-only"
                    >I'm a family member. I'm a friend. I'm someone who misses you. I'm
                    ReachOutt.</span
                  >
                  <span class="greeting" aria-hidden="true">{{ greeting }}</span>
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
const greetings = [
  "I'm a family member",
  "I'm a friend",
  "I'm someone who misses you",
  "I'm ReachOutt"
]

export default {
  methods: {
    assetPath,
    animateGreeting() {
      const phrase = greetings[this.phraseIndex]
      if (this.deleting) {
        this.greeting = this.greeting.slice(0, -1)
        if (!this.greeting) {
          this.deleting = false
          this.phraseIndex = (this.phraseIndex + 1) % greetings.length
          this.timer = window.setTimeout(this.animateGreeting, 300)
          return
        }
      } else {
        this.greeting = phrase.slice(0, this.greeting.length + 1)
        if (this.greeting === phrase) {
          this.deleting = true
          this.timer = window.setTimeout(this.animateGreeting, 2200)
          return
        }
      }
      this.timer = window.setTimeout(this.animateGreeting, this.deleting ? 45 : 85)
    }
  },
  data() {
    return { greeting: greetings[0], phraseIndex: 0, deleting: true, timer: null }
  },
  mounted() {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return
    this.timer = window.setTimeout(this.animateGreeting, 2200)
  },
  beforeUnmount() {
    window.clearTimeout(this.timer)
  }
}
</script>

<style scoped>
.greeting {
  display: inline-block;
  min-height: 1em;
}
</style>

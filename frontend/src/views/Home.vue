<template>
  <main class="home">
    <div
      class="hero-full-container background-image-container white-text-container"
      :style="{ backgroundImage: `url('${assetPath('assets/images/space.jpg')}')` }"
    >
      <div class="container">
        <div class="row">
          <div class="col-xs-12">
            <div class="hero-full-wrapper">
              <div class="text-content">
                <p class="eyebrow">Keep your people close</p>
                <h1>
                  Hello,<br />
                  <span class="sr-only"
                    >I'm a family member. I'm a friend. I'm someone who misses you. I'm
                    ReachOutt.</span
                  >
                  <span class="greeting" aria-hidden="true">{{ greeting }}</span>
                </h1>
                <p class="hero-description">
                  Life gets busy. A little reminder can bring you back to the people who matter.
                </p>
                <div class="hero-actions">
                  <router-link class="btn btn-primary" to="/reachout">Your reachouts</router-link
                  ><router-link class="btn hero-secondary" to="/about">How it works</router-link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>
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

<template>
  <main class="page container about-page">
    <header class="page-heading">
      <div>
        <p class="eyebrow">The idea behind ReachOutt</p>
        <h1>A little nudge to say hello.</h1>
        <p>Life gets busy. Your connections still matter.</p>
      </div>
    </header>
    <div class="about-layout">
      <div class="about-copy">
        <section>
          <h2>Your people, in one place</h2>
          <p>
            Add the friends and family you want to stay in touch with. Keep their details handy for
            the next time you reach out.
          </p>
        </section>
        <section>
          <h2>A rhythm that works for you</h2>
          <p>
            Choose a reminder schedule and get an email when it is time to reconnect. Pause a
            reminder whenever you need a break.
          </p>
        </section>
        <section>
          <h2>Something to start with</h2>
          <p>
            Add an optional joke, news story, or sports suggestion when you could use a little help
            starting the conversation.
          </p>
        </section>
        <router-link class="btn btn-primary" to="/contact">Start with your contacts</router-link>
      </div>
      <img :src="assetPath('assets/images/reachout_about.jpg')" alt="" class="about-photo" />
    </div>
  </main>
</template>
<script>
import { assetPath } from '../config'
export default { methods: { assetPath } }
</script>

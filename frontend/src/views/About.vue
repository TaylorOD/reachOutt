<template>
  <main class="page container how-it-works">
    <header class="page-heading">
      <div>
        <p class="eyebrow">Keep in touch</p>
        <h1>How it works</h1>
        <p>A reminder for you. A real conversation with them.</p>
      </div>
    </header>
    <div class="guide-layout">
      <ol class="guide-steps">
        <li>
          <span class="step-number" aria-hidden="true">1</span>
          <div>
            <h2>Add someone you care about</h2>
            <p>
              Start with a name. A phone number is optional, so you can keep in touch however you
              like.
            </p>
          </div>
        </li>
        <li>
          <span class="step-number" aria-hidden="true">2</span>
          <div>
            <h2>Choose your rhythm</h2>
            <p>
              Add a reminder from their contact card. Pick how often and when to start. Your
              Reachouts page shows when the next email is due.
            </p>
          </div>
        </li>
        <li>
          <span class="step-number" aria-hidden="true">3</span>
          <div>
            <h2>Get a nudge, then say hello</h2>
            <p>
              We email you when it is time. You decide whether to call, text, or catch up in person.
              ReachOutt never messages your contacts.
            </p>
          </div>
        </li>
      </ol>
      <aside class="panel example-reminder" aria-labelledby="example-title">
        <p class="eyebrow">For example</p>
        <h2 id="example-title">A weekly reminder for Sam</h2>
        <p>
          You add Sam and choose a weekly reminder. When it is due, an email arrives in your inbox:
        </p>
        <blockquote>
          <strong>Time to reach out to Sam</strong>
          <p>Hey Alex! Time to reach out to Sam.</p>
        </blockquote>
        <p>No message is sent to Sam. The next conversation is yours.</p>
      </aside>
    </div>
    <section class="guide-next">
      <div>
        <h2>Make it work for you</h2>
        <p>
          Pause a reminder whenever you need a break. You can change its frequency or add an
          optional conversation starter, included when available.
        </p>
      </div>
      <router-link class="btn btn-primary" to="/contact">Start with your contacts</router-link>
    </section>
  </main>
</template>

<style scoped>
.guide-layout {
  display: grid;
  grid-template-columns: 1.2fr 1fr;
  gap: 64px;
  align-items: start;
}
.guide-steps {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 36px;
}
.guide-steps li {
  display: flex;
  gap: 20px;
}
.step-number {
  background: #e9eee3;
  color: var(--accent);
  flex: 0 0 40px;
  height: 40px;
  display: grid;
  place-items: center;
  border-radius: 50%;
  font-weight: 700;
}
.guide-steps p,
.guide-next p {
  margin-top: 12px;
  color: var(--muted);
}
.example-reminder {
  display: grid;
  gap: 16px;
}
.example-reminder blockquote {
  margin: 8px 0;
  padding: 24px;
  background: #f6f5f0;
  border-left: 3px solid var(--accent);
}
.example-reminder blockquote p {
  margin-top: 12px;
}
.guide-next {
  margin-top: 52px;
  padding-top: 32px;
  border-top: 1px solid var(--line);
  display: flex;
  align-items: center;
  gap: 40px;
}
.guide-next .btn {
  flex-shrink: 0;
}
@media (max-width: 800px) {
  .guide-layout {
    grid-template-columns: 1fr;
    gap: 32px;
  }
  .guide-next {
    align-items: start;
    flex-direction: column;
    gap: 24px;
  }
}
</style>

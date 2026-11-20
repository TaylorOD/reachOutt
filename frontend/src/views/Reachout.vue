<template>
  <main class="page container reachout">
    <header class="page-heading">
      <div>
        <p class="eyebrow">A little nudge</p>
        <h1>Reminders</h1>
        <p>We email you a reminder. You reach out to your people.</p>
      </div>
      <button v-if="reachouts.length" class="btn btn-primary" @click="openCreate">
        Add reminder
      </button>
    </header>
    <p v-if="errorMessage" class="alert alert-danger" role="alert">{{ errorMessage }}</p>
    <p v-if="createdAlert" class="alert alert-success" role="status">Reminder saved.</p>
    <div class="list-workspace">
      <section class="collection" aria-labelledby="reachout-list-title">
        <div class="collection-heading">
          <h2 id="reachout-list-title">Your reminders</h2>
          <label v-if="reachouts.length" class="filter-field"
            ><span class="sr-only">Filter reminders</span
            ><select v-model="statusFilter" aria-label="Filter reminders">
              <option value="all">All reminders</option>
              <option value="active">Active</option>
              <option value="paused">Paused</option>
            </select></label
          >
        </div>
        <p v-if="reachouts.length" class="schedule-note">
          {{ reachouts.filter((item) => item.enabled).length }} active /
          {{ reachouts.filter((item) => !item.enabled).length }} paused. Times use your local
          timezone. Emails are checked about every 15 minutes.
        </p>
        <p v-if="loading" class="empty-state" role="status">Loading your reminders...</p>
        <div v-else-if="loadFailed" class="empty-state">
          <h3>Your reminders could not load</h3>
          <p>Try again to see your saved schedules.</p>
          <button class="btn btn-primary" @click="indexContacts">Try again</button>
        </div>
        <div v-else-if="filteredReachouts.length" class="record-grid">
          <article
            v-for="reachout in filteredReachouts"
            :key="reachout.id"
            class="record-card reminder-card"
          >
            <div class="record-top">
              <span class="status-badge" :class="{ active: reachout.enabled }"
                >Status: {{ reachout.enabled ? 'Active' : 'Paused' }}</span
              ><span class="frequency-label">{{ frequencyToName(reachout.frequency) }}</span>
            </div>
            <h3>{{ reachout.contact.first_name }} {{ reachout.contact.last_name }}</h3>
            <p class="record-detail">
              {{ reachout.topic ? `Topic: ${reachout.topic}` : 'A simple reminder to say hello' }}
            </p>
            <p class="next-email">{{ nextEmail(reachout) }}</p>
            <p v-if="!reachout.enabled" class="muted">No emails while paused.</p>
            <div class="card-actions">
              <button
                class="btn btn-default"
                :disabled="pendingIds.includes(reachout.id)"
                @click="toggleReachout(reachout)"
              >
                {{ reachout.enabled ? 'Pause reminder' : 'Resume reminder' }}</button
              ><button class="btn btn-text" @click="showReachout(reachout)">Edit reminder</button>
            </div>
          </article>
        </div>
        <div v-else class="empty-state">
          <template v-if="reachouts.length">
            <h3>No reminders in this view</h3>
            <p>Your other reminders are still here.</p>
            <button class="btn btn-default" @click="statusFilter = 'all'">
              Show all reminders
            </button>
          </template>
          <template v-else-if="contacts.length">
            <h3>A small reminder goes a long way</h3>
            <p>Pick someone you want to keep in touch with, then choose how often.</p>
            <button class="btn btn-primary" @click="openCreate">Add your first reminder</button>
          </template>
          <template v-else>
            <h3>Start with someone you care about</h3>
            <p>Add a contact first. Then choose a reminder that fits your rhythm.</p>
            <router-link class="btn btn-primary" to="/contact">Add a contact</router-link>
          </template>
        </div>
      </section>
    </div>
  </main>
  <dialog id="new-reachout" aria-labelledby="new-reachout-title" @close="clearContactQuery">
    <h2 id="new-reachout-title">Add reminder</h2>
    <p class="muted">Choose who, then pick your rhythm.</p>
    <form class="form-stack" @submit.prevent="createReachout">
      <p v-if="errorMessage" class="alert alert-danger" role="alert">{{ errorMessage }}</p>
      <label
        >Contact<select v-model="newReachoutContactID" aria-label="New ContactID" required>
          <option value="" disabled>Select a contact</option>
          <option v-for="contact in contacts" :value="contact.id" :key="contact.id">
            {{ contact.first_name }} {{ contact.last_name }}
          </option>
        </select></label
      >
      <p v-if="!loading && !contacts.length" class="muted">
        Add someone on the <router-link to="/contact">Contacts page</router-link> first.
      </p>
      <label
        >How often<select v-model="newReachoutFrequency" aria-label="New Frequency" required>
          <option value="" disabled>Select frequency</option>
          <option v-for="option in frequencies" :value="option.value" :key="option.id">
            {{ option.name }}
          </option>
        </select></label
      >
      <label
        >Conversation starter <span class="optional">Optional</span
        ><select v-model="newReachoutTopic" aria-label="New Topic">
          <option value="">No suggestion</option>
          <option>Jokes</option>
          <option>News</option>
          <option>Sports</option>
        </select></label
      >
      <label
        >Start date<input
          type="date"
          v-model="newReachoutStartDate"
          aria-label="New StartDate"
          required
      /></label>
      <button class="btn btn-primary" :disabled="saving || !contacts.length">
        {{ saving ? 'Saving...' : 'Save reminder' }}
      </button>
      <p class="form-note">
        We email you a reminder to contact {{ selectedContactName }}. ReachOutt never messages your
        contacts.
      </p>
      <button type="button" class="btn btn-default" @click="closeCreate">Cancel</button>
    </form>
  </dialog>
  <dialog id="reachout-details" aria-labelledby="reachout-dialog-title">
    <form method="dialog" class="form-stack">
      <div>
        <p class="eyebrow">Keep in touch</p>
        <h2 id="reachout-dialog-title">Edit reminder</h2>
      </div>
      <p v-if="errorMessage" role="alert" class="alert alert-danger">{{ errorMessage }}</p>
      <div class="dialog-summary">
        <p>
          Contact: {{ currentReachout.contact?.first_name }}
          {{ currentReachout.contact?.last_name }}
        </p>
        <small>Edit contact details on the Contacts page.</small>
      </div>
      <label
        >How often<select v-model="currentReachout.frequency" aria-label="Edit frequency">
          <option v-for="option in frequencies" :value="option.value" :key="option.id">
            {{ option.name }}
          </option>
        </select></label
      >
      <label
        >Conversation starter<select v-model="currentReachout.topic" aria-label="Edit topic">
          <option value="">No suggestion</option>
          <option>Jokes</option>
          <option>News</option>
          <option>Sports</option>
        </select></label
      >
      <p class="muted">Start date: {{ currentReachout.start_date }}</p>
      <div class="dialog-actions">
        <button type="button" class="btn btn-primary" @click="updateReachout(currentReachout)">
          Save reminder</button
        ><button class="btn btn-default">Close</button>
      </div>
      <div class="danger-zone">
        <button type="button" class="btn btn-danger" @click="destroyReachout(currentReachout)">
          Delete reminder
        </button>
      </div>
    </form>
  </dialog>
</template>

<script>
import axios from 'axios'
import { nextEmail, sortReminders } from '../reminders'

export default {
  data() {
    return {
      reachouts: [],
      loading: true,
      loadFailed: false,
      saving: false,
      statusFilter: 'all',
      pendingIds: [],
      frequencies: [
        { name: 'Daily', id: 1, value: '1d' },
        { name: 'Weekly', id: 2, value: '7d' },
        { name: 'Every two weeks', id: 3, value: '14d' },
        { name: 'Monthly', id: 4, value: '30d' },
        { name: 'Every two months', id: 5, value: '60d' },
        { name: 'Quarterly', id: 6, value: '90d' },
        { name: 'Every six months', id: 7, value: '182.5d' },
        { name: 'Annually', id: 8, value: '365d' }
      ],
      contacts: [],
      newReachoutStartDate: '',
      newReachoutFrequency: '',
      newReachoutContactID: '',
      newReachoutTopic: '',
      currentReachout: {},
      createdAlert: false,
      errorMessage: ''
    }
  },
  computed: {
    selectedContactName() {
      const person = this.contacts.find(
        (item) => String(item.id) === String(this.newReachoutContactID)
      )
      return person
        ? [person.first_name, person.last_name].filter(Boolean).join(' ')
        : 'the person you choose'
    },
    filteredReachouts() {
      return sortReminders(
        this.reachouts.filter(
          (item) =>
            item.contact &&
            (this.statusFilter === 'all' ||
              (this.statusFilter === 'active' ? item.enabled : !item.enabled))
        )
      )
    }
  },
  created() {
    this.indexContacts()
  },
  methods: {
    nextEmail,
    openCreate() {
      this.errorMessage = ''
      document.querySelector('#new-reachout').showModal()
    },
    closeCreate() {
      document.querySelector('#new-reachout').close()
    },
    clearContactQuery() {
      if (this.$route?.query.contact) this.$router.replace({ path: '/reachout' })
    },
    async toggleReachout(reachout) {
      if (this.pendingIds.includes(reachout.id)) return
      this.pendingIds.push(reachout.id)
      this.errorMessage = ''
      try {
        const response = await axios.patch(`/api/reachouts/${reachout.id}`, {
          enabled: !reachout.enabled
        })
        const index = this.reachouts.findIndex((item) => item.id === reachout.id)
        if (index !== -1) this.reachouts.splice(index, 1, response.data)
      } catch (error) {
        this.errorMessage = 'Could not change reminder status. Please try again.'
      } finally {
        this.pendingIds = this.pendingIds.filter((id) => id !== reachout.id)
      }
    },
    async indexContacts() {
      this.loading = true
      this.loadFailed = false
      this.errorMessage = ''
      try {
        const [contacts, reachouts] = await Promise.all([
          axios.get('/api/contacts'),
          axios.get('/api/reachouts')
        ])
        this.contacts = contacts.data
        this.reachouts = reachouts.data
        const contactId = this.$route?.query.contact
        if (contactId && this.contacts.some((item) => String(item.id) === String(contactId))) {
          this.newReachoutContactID = Number(contactId)
          this.openCreate()
        }
      } catch {
        this.loadFailed = true
      } finally {
        this.loading = false
      }
    },
    createReachout() {
      if (this.saving) return
      this.saving = true
      this.errorMessage = ''
      const params = {
        start_date: this.newReachoutStartDate,
        frequency: this.newReachoutFrequency,
        contact_id: this.newReachoutContactID,
        topic: this.newReachoutTopic
      }
      axios
        .post('/api/reachouts', params)
        .then((response) => {
          this.reachouts.push(response.data)

          this.newReachoutStartDate = ''
          this.newReachoutFrequency = ''
          this.newReachoutContactID = ''
          this.newReachoutTopic = ''
          this.createdAlert = true
          this.closeCreate()
        })
        .catch((error) => {
          this.errorMessage =
            error.response?.data?.errors?.join(' ') || 'Could not create reminder.'
        })
        .finally(() => {
          this.saving = false
        })
    },
    showReachout(reachout) {
      this.errorMessage = ''
      this.currentReachout = { ...reachout }
      document.querySelector('#reachout-details').showModal()
    },
    updateReachout(reachout) {
      const params = {
        start_date: reachout.start_date,
        frequency: reachout.frequency,
        topic: reachout.topic
      }
      axios
        .patch(`/api/reachouts/${reachout.id}`, params)
        .then((response) => {
          const index = this.reachouts.findIndex((item) => item.id === reachout.id)
          if (index !== -1) this.reachouts.splice(index, 1, response.data)
          document.querySelector('#reachout-details').close()
        })
        .catch((error) => {
          this.errorMessage = error.response?.data?.errors?.join(' ') || 'Could not save reminder.'
        })
    },
    destroyReachout(reachout) {
      axios
        .delete(`/api/reachouts/${reachout.id}`)
        .then((response) => {
          const index = this.reachouts.findIndex((item) => item.id === reachout.id)
          if (index !== -1) this.reachouts.splice(index, 1)
          document.querySelector('#reachout-details').close()
        })
        .catch((error) => {
          this.errorMessage = error.response?.data?.errors?.join(' ') || 'Could not save reminder.'
        })
    },
    frequencyToName(frequency) {
      return this.frequencies.find((option) => option.value === frequency)?.name || frequency
    },
    dismissAlert() {
      this.createdAlert = false
    }
  }
}
</script>

<style scoped>
.empty-state .btn {
  margin-top: 20px;
}
</style>

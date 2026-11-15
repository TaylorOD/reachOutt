<template>
  <main class="page container reachout">
    <header class="page-heading">
      <div>
        <p class="eyebrow">A little nudge</p>
        <h1>Reachouts</h1>
        <p>Make time for the people who matter.</p>
      </div>
      <span class="count-label"
        >{{ reachouts.filter((item) => item.enabled).length }} active /
        {{ reachouts.filter((item) => !item.enabled).length }} paused</span
      >
    </header>
    <p v-if="errorMessage" class="alert alert-danger" role="alert">{{ errorMessage }}</p>
    <p v-if="createdAlert" class="alert alert-success" role="status">New reachout created.</p>
    <div class="workspace">
      <section class="panel create-panel" aria-labelledby="new-reachout-title">
        <h2 id="new-reachout-title">New reachout</h2>
        <p class="muted">Choose who, then pick your rhythm.</p>
        <form class="form-stack" @submit.prevent="createReachout">
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
            {{ saving ? 'Creating...' : 'Create Reachout' }}
          </button>
          <p class="form-note">Reminders arrive by email. You can pause them anytime.</p>
        </form>
      </section>
      <section class="collection" aria-labelledby="reachout-list-title">
        <div class="collection-heading">
          <h2 id="reachout-list-title">Your reachouts</h2>
          <label class="filter-field"
            ><span class="sr-only">Filter reminders</span
            ><select v-model="statusFilter" aria-label="Filter reminders">
              <option value="all">All reminders</option>
              <option value="active">Active</option>
              <option value="paused">Paused</option>
            </select></label
          >
        </div>
        <p v-if="loading" class="empty-state" role="status">Loading your reachouts...</p>
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
            <p class="record-detail">Start date: {{ reachout.start_date }}</p>
            <div class="card-actions">
              <button
                class="btn btn-default"
                :disabled="pendingIds.includes(reachout.id)"
                @click="toggleReachout(reachout)"
              >
                {{ reachout.enabled ? 'Pause reminder' : 'Resume reminder' }}</button
              ><button class="btn btn-text" @click="showReachout(reachout)">Edit Reachout</button>
            </div>
          </article>
        </div>
        <div v-else class="empty-state">
          <h3>
            {{
              reachouts.length ? 'No reminders in this view' : 'A small reminder goes a long way'
            }}
          </h3>
          <p>
            {{
              reachouts.length
                ? 'Choose another filter to see your reachouts.'
                : 'Choose a contact and create your first reachout.'
            }}
          </p>
        </div>
      </section>
    </div>
  </main>
  <dialog id="reachout-details" aria-labelledby="reachout-dialog-title">
    <form method="dialog" class="form-stack">
      <div>
        <p class="eyebrow">Keep in touch</p>
        <h2 id="reachout-dialog-title">Edit reachout</h2>
      </div>
      <p v-if="errorMessage" role="alert" class="alert alert-danger">{{ errorMessage }}</p>
      <div class="dialog-summary">
        <p>
          Contact Name: {{ currentReachout.contact?.first_name }}
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
          Update</button
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

export default {
  data() {
    return {
      reachouts: [],
      loading: true,
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
    filteredReachouts() {
      return this.reachouts.filter(
        (item) =>
          item.contact &&
          (this.statusFilter === 'all' ||
            (this.statusFilter === 'active' ? item.enabled : !item.enabled))
      )
    }
  },
  created() {
    this.indexContacts()
  },
  methods: {
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
      try {
        const [contacts, reachouts] = await Promise.all([
          axios.get('/api/contacts'),
          axios.get('/api/reachouts')
        ])
        this.contacts = contacts.data
        this.reachouts = reachouts.data
      } catch {
        this.errorMessage = 'Could not load your reachouts. Please refresh and try again.'
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

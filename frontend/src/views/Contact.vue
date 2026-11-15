<template>
  <main class="page container contacts">
    <header class="page-heading">
      <div>
        <p class="eyebrow">Your people</p>
        <h1>Contacts</h1>
        <p>Keep the people you care about close.</p>
      </div>
      <button class="btn btn-primary" @click="openCreate">Add contact</button>
    </header>
    <p v-if="createdAlert" class="alert alert-success" role="status">
      Contact added.
      <router-link
        v-if="createdContactId"
        :to="{ path: '/reachout', query: { contact: createdContactId } }"
        >Add their first reminder</router-link
      >
    </p>
    <p v-if="errorMessage" class="alert alert-danger" role="alert">{{ errorMessage }}</p>
    <div class="list-workspace">
      <section class="collection" aria-labelledby="contact-list-title">
        <div class="collection-heading">
          <h2 id="contact-list-title">
            Your contacts <span class="count-label">{{ contacts.length }}</span>
          </h2>
          <label class="search-field"
            ><span class="sr-only">Search contacts</span
            ><input
              type="search"
              v-model="search"
              placeholder="Find someone..."
              aria-label="Search contacts"
          /></label>
        </div>
        <p v-if="loading" class="empty-state" role="status">Loading your contacts...</p>
        <div v-else-if="filteredContacts.length" class="record-grid">
          <article
            v-for="contact in filteredContacts"
            :key="contact.id"
            class="record-card contact-card"
          >
            <div class="person-heading">
              <span class="avatar" aria-hidden="true"
                >{{ contact.first_name?.slice(0, 1) }}{{ contact.last_name?.slice(0, 1) }}</span
              >
              <div>
                <h3>{{ contact.first_name }} {{ contact.last_name }}</h3>
                <p class="muted">{{ contact.phone_number || 'No phone number' }}</p>
              </div>
            </div>
            <p class="muted">{{ reminderSummary(contact.id) }}</p>
            <div class="card-actions">
              <router-link
                class="btn btn-primary"
                :to="{ path: '/reachout', query: { contact: contact.id } }"
                >Add reminder</router-link
              ><button class="btn btn-text" @click="showContact(contact)">Edit Contact</button>
            </div>
          </article>
        </div>
        <div v-else class="empty-state">
          <h3>{{ search ? 'No matching contacts' : 'Make room for your people' }}</h3>
          <p>
            {{
              search
                ? 'Try another name or phone number.'
                : 'Add your first contact to get started.'
            }}
          </p>
        </div>
      </section>
    </div>
  </main>
  <dialog id="new-contact" aria-labelledby="new-contact-title">
    <h2 id="new-contact-title">New contact</h2>
    <p class="muted">A name is enough to get started.</p>
    <form class="form-stack" @submit.prevent="createContact">
      <p v-if="errorMessage" class="alert alert-danger" role="alert">{{ errorMessage }}</p>
      <label
        >First name<input
          v-model="newContactFirstName"
          aria-label="New FirstName"
          autocomplete="given-name"
          required
      /></label>
      <label
        >Last name <span class="optional">Optional</span
        ><input v-model="newContactLastName" aria-label="New LastName" autocomplete="family-name"
      /></label>
      <label
        >Phone number <span class="optional">Optional</span
        ><input
          type="tel"
          v-model="newContactPhoneNumber"
          aria-label="New PhoneNumber"
          autocomplete="tel"
          placeholder="+1 202 555 0100"
      /></label>
      <button class="btn btn-primary" :disabled="saving">
        {{ saving ? 'Adding...' : 'Create Contact' }}
      </button>
      <button type="button" class="btn btn-default" @click="closeCreate">Cancel</button>
    </form>
  </dialog>
  <dialog id="contact-details" aria-labelledby="contact-dialog-title">
    <form method="dialog" class="form-stack">
      <div>
        <p class="eyebrow">Your people</p>
        <h2 id="contact-dialog-title">Edit contact</h2>
      </div>
      <p v-if="errorMessage" role="alert" class="alert alert-danger">{{ errorMessage }}</p>
      <label
        >First name<input v-model="currentContact.first_name" aria-label="Edit first name"
      /></label>
      <label
        >Last name <span class="optional">Optional</span
        ><input v-model="currentContact.last_name" aria-label="Edit last name"
      /></label>
      <label
        >Phone number <span class="optional">Optional</span
        ><input type="tel" v-model="currentContact.phone_number" aria-label="Edit phone number"
      /></label>
      <div class="dialog-actions">
        <button type="button" class="btn btn-primary" @click="updateContact(currentContact)">
          Update</button
        ><button class="btn btn-default">Close</button>
      </div>
      <div class="danger-zone">
        <p>Deleting this contact also removes their reminders.</p>
        <button type="button" class="btn btn-danger" @click="destroyContact(currentContact)">
          Delete contact
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
      contacts: [],
      reachouts: [],
      remindersLoaded: false,
      createdContactId: null,
      search: '',
      loading: true,
      saving: false,
      newContactFirstName: '',
      newContactLastName: '',
      newContactPhoneNumber: '',
      currentContact: {},
      createdAlert: false,
      errorMessage: ''
    }
  },
  computed: {
    filteredContacts() {
      const query = this.search.trim().toLowerCase()
      return this.contacts.filter((contact) =>
        `${contact.first_name} ${contact.last_name || ''} ${contact.phone_number || ''}`
          .toLowerCase()
          .includes(query)
      )
    }
  },
  created() {
    this.indexContacts()
    this.loadReminders()
  },
  methods: {
    openCreate() {
      this.errorMessage = ''
      document.querySelector('#new-contact').showModal()
    },
    closeCreate() {
      document.querySelector('#new-contact').close()
    },
    async loadReminders() {
      try {
        this.reachouts = (await axios.get('/api/reachouts')).data
        this.remindersLoaded = true
      } catch {
        this.remindersLoaded = false
      }
    },
    reminderSummary(id) {
      if (!this.remindersLoaded) return 'Reminder status unavailable'
      const reminders = this.reachouts.filter((item) => item.contact_id === id)
      if (!reminders.length) return 'No reminders yet'
      const active = reminders.filter((item) => item.enabled).length
      return `${active} active / ${reminders.length - active} paused`
    },
    async indexContacts() {
      try {
        const response = await axios.get('/api/contacts')
        this.contacts = response.data
      } catch (error) {
        this.errorMessage = 'Failed to load contacts.'
      } finally {
        this.loading = false
      }
    },
    async createContact() {
      if (this.saving) return
      if (!this.newContactFirstName.trim()) {
        this.errorMessage = 'Enter a name for your contact.'
        return
      }
      this.errorMessage = ''
      this.saving = true
      try {
        const response = await axios.post('/api/contacts', {
          first_name: this.newContactFirstName.trim(),
          last_name: this.newContactLastName,
          phone_number: this.newContactPhoneNumber
        })
        this.contacts.unshift(response.data)
        this.newContactFirstName = ''
        this.newContactLastName = ''
        this.newContactPhoneNumber = ''
        this.createdAlert = true
        this.createdContactId = response.data.id
        this.closeCreate()
      } catch (error) {
        this.errorMessage = 'Failed to create contact.'
      } finally {
        this.saving = false
      }
    },
    showContact(contact) {
      this.errorMessage = ''
      this.currentContact = { ...contact }
      document.querySelector('#contact-details').showModal()
    },
    async updateContact(contact) {
      const params = {
        first_name: contact.first_name,
        last_name: contact.last_name,
        phone_number: contact.phone_number
      }
      try {
        const response = await axios.patch(`/api/contacts/${contact.id}`, params)
        const index = this.contacts.findIndex((item) => item.id === contact.id)
        this.contacts.splice(index, 1, response.data)
        document.querySelector('#contact-details').close()
      } catch (error) {
        this.errorMessage = 'Failed to update contact.'
      }
    },
    async destroyContact(contact) {
      try {
        await axios.delete(`/api/contacts/${contact.id}`)
        const index = this.contacts.findIndex((item) => item.id === contact.id)
        this.contacts.splice(index, 1)
        document.querySelector('#contact-details').close()
      } catch (error) {
        this.errorMessage = 'Failed to delete contact.'
      }
    },
    dismissAlert() {
      this.createdAlert = false
      this.errorMessage = ''
    }
  }
}
</script>

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { createApp, nextTick } from 'vue'
import axios from 'axios'
import Contact from './Contact.vue'
import Reachout from './Reachout.vue'
import Signup from './Signup.vue'

vi.mock('axios', () => ({ default: { get: vi.fn(), post: vi.fn(), patch: vi.fn(), delete: vi.fn() } }))

let app
const flush = async () => { await new Promise(resolve => setTimeout(resolve, 0)); await nextTick() }
function mount(component) {
  const node = document.createElement('div')
  document.body.append(node)
  app = createApp(component)
  return app.mount(node)
}

beforeEach(() => {
  axios.get.mockResolvedValue({ data: [] })
  HTMLDialogElement.prototype.showModal = function () { this.open = true }
  HTMLDialogElement.prototype.close = function () { this.open = false }
})
afterEach(() => { app?.unmount(); document.body.innerHTML = ''; vi.resetAllMocks() })

describe('contact edits', () => {
  it('keeps edits separate until the server accepts them and only renders one dialog', async () => {
    const contacts = [{ id: 1, first_name: 'Sam' }, { id: 2, first_name: 'Alex' }]
    axios.get.mockResolvedValue({ data: contacts })
    const page = mount(Contact)
    await flush()
    expect(document.querySelectorAll('dialog')).toHaveLength(1)
    page.showContact(page.contacts[1])
    page.currentContact.first_name = 'Changed'
    expect(page.contacts[1].first_name).toBe('Alex')
    axios.patch.mockResolvedValue({ data: { id: 2, first_name: 'Changed' } })
    await page.updateContact(page.currentContact)
    expect(page.contacts.map(item => item.first_name)).toEqual(['Sam', 'Changed'])
    expect(document.querySelector('dialog').open).toBe(false)
  })

  it('keeps the dialog and original contact when saving fails', async () => {
    const page = mount(Contact)
    await flush()
    page.contacts = [{ id: 1, first_name: 'Sam' }]
    page.showContact(page.contacts[0])
    axios.patch.mockRejectedValue(new Error('offline'))
    await page.updateContact(page.currentContact)
    expect(page.errorMessage).toBe('Failed to update contact.')
    expect(document.querySelector('dialog').open).toBe(true)
  })
})

describe('reminder edits', () => {
  it('saves the edited topic and replaces the correct reminder', async () => {
    const page = mount(Reachout)
    await flush()
    page.reachouts = [{ id: 1, topic: 'News', contact: { first_name: 'Sam' } }, { id: 2, topic: 'News', contact: { first_name: 'Alex' } }]
    await nextTick()
    expect(document.querySelectorAll('dialog')).toHaveLength(1)
    page.showReachout(page.reachouts[1])
    page.currentReachout.topic = 'Sports'
    axios.patch.mockResolvedValue({ data: { ...page.currentReachout } })
    page.updateReachout(page.currentReachout)
    await flush()
    expect(axios.patch).toHaveBeenCalledWith('/api/reachouts/2', expect.objectContaining({ topic: 'Sports' }))
    expect(page.reachouts.map(item => item.topic)).toEqual(['News', 'Sports'])
  })

  it('shows API validation errors', async () => {
    const page = mount(Reachout)
    await flush()
    axios.post.mockRejectedValue({ response: { data: { errors: ['Start date must be a valid date'] } } })
    page.createReachout()
    await flush()
    expect(page.errorMessage).toContain('Start date')
  })
})

it('handles signup when the server cannot be reached', async () => {
  const page = mount(Signup)
  axios.post.mockRejectedValue(new Error('offline'))
  page.submit()
  await flush()
  expect(page.errors).toEqual(['Could not sign up. Please try again.'])
})

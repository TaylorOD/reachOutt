import { AxiosError } from 'axios'

const account = {
  id: 1, first_name: 'Alex', last_name: 'Example',
  email: 'alex@example.test', phone_number: '+12025550100'
}
const contacts = [
  { id: 1, first_name: 'Sam', last_name: 'Example', phone_number: '+12025550101' },
  { id: 2, first_name: 'Jordan', last_name: 'Example', phone_number: '+12025550102' }
]
const reachouts = contacts.map((contact, index) => ({
  id: contact.id, contact_id: contact.id, contact,
  frequency: '7d', start_date: '2030-01-01', topic: index ? 'Jokes' : 'News', enabled: !index
}))
const pages = { '/api/account': account, '/api/contacts': contacts, '/api/reachouts': reachouts }

// This adapter replaces all HTTP transport in preview builds, including writes.
export async function previewAdapter(config) {
  const response = { config, headers: {}, status: 200, statusText: 'OK' }
  if (config.method === 'get' && Object.hasOwn(pages, config.url)) {
    return { ...response, data: structuredClone(pages[config.url]) }
  }
  const message = 'This preview uses fictional data. Changes and messages are disabled.'
  response.status = 403
  response.statusText = 'Forbidden'
  response.data = { errors: [message] }
  throw new AxiosError(message, 'ERR_BAD_REQUEST', config, null, response)
}

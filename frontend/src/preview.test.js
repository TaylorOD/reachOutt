import { describe, expect, it } from 'vitest'
import axios from 'axios'
import { previewAdapter } from './preview'

const client = axios.create({ adapter: previewAdapter })
describe('preview transport', () => {
  it('returns independent fictional records', async () => {
    const first = await client.get('/api/contacts')
    first.data[0].first_name = 'Changed'
    const second = await client.get('/api/contacts')
    expect(second.data[0].first_name).toBe('Sam')
  })
  it('blocks writes and unknown URLs without a network fallback', async () => {
    await expect(
      client.post('/api/password_resets', { email: 'real@example.test' })
    ).rejects.toMatchObject({ response: { status: 403 } })
    await expect(client.get('https://example.com/api/account')).rejects.toMatchObject({
      response: { status: 403 }
    })
  })
})

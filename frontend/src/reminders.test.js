import { describe, expect, it } from 'vitest'
import { nextEmail, sortReminders } from './reminders'

describe('reminder schedules', () => {
  it('puts due reminders first and paused reminders after active ones', () => {
    const reminders = [
      { id: 1, enabled: false, next_send_at: '2020-01-01T00:00:00Z' },
      { id: 2, enabled: true, next_send_at: '2030-02-01T00:00:00Z' },
      { id: 3, enabled: true, next_send_at: '2030-01-01T00:00:00Z' },
      { id: 4, enabled: true, next_send_at: null }
    ]
    expect(sortReminders(reminders).map((item) => item.id)).toEqual([3, 2, 4, 1])
    expect(reminders[0].id).toBe(1)
  })
  it('never presents paused or unknown schedules as upcoming deliveries', () => {
    expect(nextEmail({ enabled: false, next_send_at: '2020-01-01' })).toBe('Next email: paused')
    expect(nextEmail({ enabled: true, next_send_at: null })).toContain('unavailable')
    expect(nextEmail({ enabled: true, next_send_at: 'invalid' })).toContain('unavailable')
    expect(nextEmail({ enabled: true, next_send_at: '2020-01-01' })).toBe('Next email: due now')
    expect(nextEmail({ enabled: true, next_send_at: '2030-01-01T12:00:00Z' }, 0)).toContain('2030')
  })
})

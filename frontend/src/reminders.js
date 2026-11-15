function sendTime(reminder) {
  const timestamp = Date.parse(reminder.next_send_at)
  return Number.isFinite(timestamp) ? timestamp : Infinity
}

export function sortReminders(reminders) {
  return [...reminders].sort(
    (a, b) => Number(b.enabled) - Number(a.enabled) || sendTime(a) - sendTime(b) || a.id - b.id
  )
}

export function nextEmail(reminder, now = Date.now()) {
  if (!reminder.enabled) return 'Next email: paused'
  const timestamp = sendTime(reminder)
  if (!Number.isFinite(timestamp)) return 'Next email: schedule unavailable'
  if (timestamp <= now) return 'Next email: due now'
  return `Next email: ${new Intl.DateTimeFormat(undefined, {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
    timeZoneName: 'short'
  }).format(timestamp)}`
}

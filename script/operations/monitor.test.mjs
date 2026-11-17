import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFile } from 'node:fs/promises'

// Exercise the real monitor without network calls or production credentials.
test('retired reminders are never checked, while backup alerts still work', async () => {
  const originalFetch = globalThis.fetch
  const originalEnv = { ...process.env }
  const calls = []
  const marker = '<!-- reachoutt-operations-alert -->'
  process.env.GITHUB_REPOSITORY = 'TaylorOD/reachOutt'
  process.env.BACKUPS_ENABLED = 'true'
  process.env.REMINDERS_ENABLED = 'true' // stale production setting must be harmless
  process.env.TEST_ALERT = 'false'
  globalThis.fetch = async (url, options) => {
    const path = url.replace('https://api.github.com/repos/TaylorOD/reachOutt', '')
    const body = options.body && JSON.parse(options.body)
    calls.push({ path, method: options.method, body })
    let result = {}
    if (path.startsWith('/issues?')) result = [
      { number: 188, title: 'Scheduled reminders needs attention', body: marker },
      { number: 189, title: 'Scheduled reminders needs attention', body: marker },
      { number: 190, title: 'Scheduled reminders needs attention', body: 'human issue' },
      { number: 191, title: 'Database backup needs attention', body: marker },
      { number: 192, title: 'Scheduled reminders needs attention', body: marker, pull_request: {} }
    ]
    else if (path === '/actions/workflows/database-backup.yml/runs?branch=main&per_page=100') {
      result = { workflow_runs: [{ event: 'schedule', status: 'completed', conclusion: 'failure', html_url: 'https://example.test/run' }] }
    } else assert.ok(['/issues/188', '/issues/189', '/issues/191'].includes(path), 'unexpected request: ' + path)
    return { ok: true, json: async () => result }
  }
  try {
    await import('./monitor.mjs')
    assert.deepEqual(calls.filter(call => call.body?.state === 'closed').map(call => [call.path, call.body.state_reason]), [
      ['/issues/188', 'not_planned'], ['/issues/189', 'not_planned']
    ])
    assert.ok(calls.some(call => call.path === '/issues/191' && /failure/.test(call.body.body)))
    assert.ok(!calls.some(call => call.path.includes('reminders.yml')))
  } finally {
    globalThis.fetch = originalFetch
    process.env = originalEnv
  }
})

test('automatic reminder workflow is absent and monitor does not subscribe to it', async () => {
  await assert.rejects(readFile(new URL('../../.github/workflows/reminders.yml', import.meta.url)), { code: 'ENOENT' })
  const monitor = await readFile(new URL('../../.github/workflows/operations-monitor.yml', import.meta.url), 'utf8')
  assert.ok(monitor.includes('workflows: [Database backup]'))
  assert.ok(!monitor.includes('REMINDERS_ENABLED'))
})

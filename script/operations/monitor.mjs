import { workflowProblem } from './status.mjs'

const repository = process.env.GITHUB_REPOSITORY
if (repository !== 'TaylorOD/reachOutt') throw new Error('Unexpected repository')
const root = 'https://api.github.com/repos/' + repository
async function api(path, method = 'GET', body) {
  const response = await fetch(root + path, {
    method,
    headers: {
      Authorization: 'Bearer ' + process.env.GITHUB_TOKEN,
      Accept: 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
      'Content-Type': 'application/json'
    },
    body: body ? JSON.stringify(body) : undefined
  })
  if (!response.ok) throw new Error('GitHub request failed: ' + response.status + ' ' + path)
  return response.json()
}

const marker = '<!-- reachoutt-operations-alert -->'
const issues = []
for (let page = 1; ; page++) {
  const batch = await api('/issues?state=open&per_page=100&page=' + page)
  issues.push(...batch.filter(issue => !issue.pull_request && issue.body?.includes(marker)))
  if (batch.length < 100) break
}
async function alert(name, problem, runUrl) {
  const title = name + ' needs attention'
  const existing = issues.find(issue => issue.title === title)
  if (!problem) {
    if (existing) await api('/issues/' + existing.number, 'PATCH', { state: 'closed', state_reason: 'completed' })
    console.log(name + ': healthy')
    return
  }
  const body = marker + '\n\n' + problem + '\n\n' + runUrl +
    '\n\nCheck the run logs and fix the cause before retrying. No credentials or customer data are included in this alert.'
  if (!existing) {
    await api('/issues', 'POST', { title, body, assignees: ['TaylorOD'] })
  } else if (existing.body !== body) {
    await api('/issues/' + existing.number, 'PATCH', { body })
  }
  console.log(name + ': attention needed')
}
for (const job of [
  { name: 'Database backup', file: 'database-backup.yml', enabled: process.env.BACKUPS_ENABLED, hours: 28 },
  { name: 'Scheduled reminders', file: 'reminders.yml', enabled: process.env.REMINDERS_ENABLED, hours: 1 }
]) {
  if (job.enabled !== 'true') {
    console.log(job.name + ': intentionally disabled')
    continue
  }
  const result = await api('/actions/workflows/' + job.file + '/runs?branch=main&per_page=100')
  const runs = result.workflow_runs.filter(run => ['schedule', 'workflow_dispatch'].includes(run.event))
  const problem = workflowProblem(runs, job.hours)
  await alert(job.name, problem, runs[0]?.html_url || 'https://github.com/' + repository + '/actions/workflows/' + job.file)
}
if (process.env.TEST_ALERT === 'true') {
  await alert('Monitoring test', 'This is a requested test of the alert connection. Close this issue after checking the notification.',
    'https://github.com/' + repository + '/actions/runs/' + process.env.GITHUB_RUN_ID)
}

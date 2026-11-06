export function workflowProblem(runs, maxAgeHours, now = Date.now()) {
  const completed = runs.filter(run => run.status === 'completed' && run.conclusion !== 'skipped')
  const latest = completed[0]
  if (!latest) return 'No completed run was found.'
  if (latest.conclusion !== 'success') return 'The latest run ended with ' + latest.conclusion + '.'
  if (now - Date.parse(latest.created_at) > maxAgeHours * 3600000) {
    return 'No successful run has started within ' + maxAgeHours + ' hours.'
  }
  return null
}

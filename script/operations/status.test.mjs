import { test } from 'node:test'
import assert from 'node:assert/strict'
import { workflowProblem } from './status.mjs'

const now = Date.parse('2026-11-06T12:00:00Z')
const success = { status: 'completed', conclusion: 'success', created_at: '2026-11-06T11:30:00Z' }
test('recent success is healthy', () => assert.equal(workflowProblem([success], 1, now), null))
test('failure is reported even when an earlier run passed', () => {
  assert.match(workflowProblem([{ ...success, conclusion: 'failure' }, success], 1, now), /failure/)
})
test('cancelled and timed out runs are reported', () => {
  for (const conclusion of ['cancelled', 'timed_out']) {
    assert.match(workflowProblem([{ ...success, conclusion }], 1, now), new RegExp(conclusion))
  }
})
test('skipped and unfinished runs cannot hide a stale schedule', () => {
  const old = { ...success, created_at: '2026-11-04T11:30:00Z' }
  assert.match(workflowProblem([{ ...success, status: 'in_progress' }, { ...success, conclusion: 'skipped' }, old], 28, now), /28 hours/)
})
test('missing history needs attention', () => assert.match(workflowProblem([], 1, now), /No completed/))

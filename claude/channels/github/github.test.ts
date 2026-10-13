import { expect, test } from 'bun:test'
import { createHmac } from 'node:crypto'
import { beatName, parsePr, secret, summarise, verified } from './github'

const pr = { number: 7, title: 't', html_url: 'u', merged: true, user: { login: 'me' } }
const base = { repository: { full_name: 'o/r' }, sender: { login: 'bot' } }

test('signature', () => {
  const sig = 'sha256=' + createHmac('sha256', secret).update('x').digest('hex')
  expect(verified('x', sig)).toBe(true)
  expect(verified('y', sig)).toBe(false)
  expect(verified('x', null)).toBe(false)
})

test('summarise', () => {
  expect(summarise('pull_request', { ...base, action: 'closed', number: 7, pull_request: pr })?.text).toStartWith('PR merged by bot')
  const review = (state: string, body: string | null) =>
    summarise('pull_request_review', { ...base, action: 'submitted', pull_request: pr, review: { state, body, html_url: 'h' } })
  expect(review('commented', null)).toBeNull()
  expect(review('approved', null)?.text).toStartWith('Review approved')
  expect(summarise('pull_request', { ...base, action: 'closed', number: 7, pull_request: pr })?.done).toBe(true)
  expect(summarise('pull_request', { ...base, action: 'synchronize', number: 7, pull_request: pr })).toBeNull()
  const c = summarise('pull_request_review_comment', {
    ...base,
    action: 'created',
    pull_request: pr,
    comment: { path: 'a.py', line: 3, html_url: 'h', body: 'x'.repeat(2000) },
  })
  expect(c?.text).toContain('a.py:3')
  expect(c?.text).toEndWith('[truncated]')
  expect(summarise('issue_comment', { ...base, action: 'created', issue: { number: 1, user: { login: 'me' } }, comment: {} })).toBeNull() // plain issue
  expect(summarise('check_suite', { ...base, action: 'completed', check_suite: { conclusion: 'skipped' } })).toBeNull()
  expect(summarise('check_suite', { ...base, action: 'completed', check_suite: { conclusion: 'failure', pull_requests: [] } })).toBeNull()
})

test('parsePr', () => {
  expect(parsePr('https://github.com/two-inc/zendesk-agent/pull/33/files')).toBe('two-inc/zendesk-agent#33')
  expect(parsePr('Two-Inc/zendesk-agent#33')).toBe('Two-Inc/zendesk-agent#33')
  expect(parsePr('33')).toBeNull()
})

test('beatName matches pr-watch-beat.sh', () => {
  const url = 'https://github.com/two-inc/zendesk-agent/pull/33'
  const sh = Bun.spawnSync(['sed', '-E', 's#https://github.com/##; s#/pull/#_#; s#/#_#g'], { stdin: Buffer.from(url) })
    .stdout.toString()
    .trim()
  expect(beatName(parsePr(url)!)).toBe(sh)
})

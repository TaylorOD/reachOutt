# Working on ReachOutt

Keep changes small and follow the existing Rails and Vue structure. Comments should explain a constraint or decision that the code cannot explain on its own. Remove dead code instead of leaving it commented out.

## Where things live

| Folder | Purpose |
| --- | --- |
| `app/controllers/api` | JSON endpoints, authentication checks, and request validation |
| `app/models` | Database relationships and reminder schedule rules |
| `app/services` | Reminder delivery, due schedule selection, and worker loop |
| `app/mailers` | Password reset email |
| `frontend/src/views` | Vue screens and their form state |
| `frontend/src/router` | Routes and the login guard |
| `frontend/src/api.js` | Shared HTTP configuration and expired login handling |
| `frontend/src/preview.js` | Fictional records and blocked HTTP transport for PR previews |
| `test/integration` | Requests against Rails and PostgreSQL |
| `test/models` | Schedule, worker, delivery, and concurrency tests |
| `test/browser` | Desktop and mobile flows against Rails |
| `test/preview` | Static preview routes, images, and request isolation |
| `script/security` | Focused checks for earlier security fixes |

## Reminders

Requests save schedules. They never send texts directly. `ReminderWorker` calls `ReminderDispatcher`, which locks each due record, checks its enabled state again, sends through `ReminderDelivery`, and records the next due time. PostgreSQL keeps that state across process restarts.

Keep the row lock around both delivery and the schedule update. It prevents two workers from sending the same due reminder together. A process crash after Twilio accepts a text can still cause a duplicate on retry. Pausing also takes the record lock. Resuming waits a full interval and does not send a backlog.

## Accounts

Every private endpoint checks a bearer token and scopes records to the current user. Tokens expire after 24 hours. Password resets use a signed token that expires after 15 minutes. Completing a reset increments `session_version`, which invalidates previous login and reset tokens. Changing an email requires the current password and invalidates reset links sent to the old address.

Do not return password digests or log reset tokens. Email links use configured `APP_URL`, never the request host. SMS and production email need explicit provider configuration.

## Frontend

Keep form edits separate from the displayed record until the API accepts them. Update lists by record ID. Use `assetPath` for public images so normal builds and nested PR previews both work.

`VITE_PR_PREVIEW=true` selects the fictional transport at build time. It does not connect to Rails. Preview routing uses URL hashes because Pages cannot serve Rails routes. Normal builds keep their existing history routes and API behavior.

Run `npm run format` after changing frontend code or JavaScript tests. `npm run format:check` checks the same files without rewriting them. Keep Ruby code in the existing two space style. Run the tests listed in the README before opening a PR and check affected screens in a browser at desktop and mobile sizes.

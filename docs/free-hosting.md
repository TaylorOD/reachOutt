# Free hosting

Use one free Render web service and a free Neon PostgreSQL project. GitHub Pages remains the place for fictional PR previews. It cannot run Rails.

This is suitable for a small beta with delays and usage limits. Render sleeps after 15 minutes without traffic and can take about a minute to wake. Its 750 free instance hours are shared across the workspace. Neon also has compute, storage, and transfer limits. Neither service is an always available guarantee.

## Deploy

1. Create a Neon project on the Free plan, near Render's Oregon region. Choose PostgreSQL 18 and keep autosuspend enabled. This is a fresh database.
2. Run `neon init` to link your existing project, then `neon deploy`. Neon writes DATABASE_URL and DATABASE_URL_UNPOOLED into the ignored .env.local file, or .env if it already exists. Keep both private.
3. In Render, create a Blueprint from this repository and its main branch. Review that it contains only one web service with plan Free. There is no Render database or paid worker.
4. Enter both connection strings in Render. DATABASE_URL is pooled for app traffic. DATABASE_URL_UNPOOLED is direct for migrations. Render generates SECRET_KEY_BASE once. Keep this value stable across deploys.
5. Deploy and check /health/ready. The start script runs migrations before starting the server. A failed migration prevents startup.
6. Open the app and create a test account. Add a contact and a paused reminder. Restart the web service and confirm both records remain.

Render supplies the default public address through RENDER_EXTERNAL_URL. Set APP_URL to your trusted HTTPS origin if you add a custom domain. Never use a PR preview address for password resets.

Rails keeps its existing Active Record and pg driver. It loads the ignored local environment file automatically in development. Run `bundle exec ruby bin/migrate` to apply migrations through the direct connection, then `bundle exec rails server`. The same migration command runs during Render and Heroku releases. Neon provides the database here. The Rails web app still needs its separate host.

Keep backend unit tests on a disposable local database. Rails does not load .env.local in the test environment. Do not export the production DATABASE_URL into a test terminal. Browser tests target the running app, so only point E2E_BASE_URL at an app where fictional test records are acceptable.

## Email

The live app uses Brevo for password reset emails. Save these settings privately in Render:

| Setting | Value |
| --- | --- |
| SMTP_ADDRESS | smtp-relay.brevo.com |
| SMTP_PORT | 2525 |
| SMTP_USERNAME | The SMTP login shown in your Brevo account |
| SMTP_PASSWORD | A dedicated SMTP key, not an API key |
| MAIL_FROM | ReachOutt followed by your verified sender address in angle brackets |

Rails requires STARTTLS and checks certificates. Port 2525 works with Render's free service, which blocks outbound SMTP ports 25, 465, and 587. Do not disable TLS to work around delivery errors.

Complete Brevo account verification and verify your sender before sending. A Gmail sender can be rewritten to a brevosend.com address by Brevo. A verified domain is a future deliverability improvement, not a requirement for the tested beta setup.

On November 6, 2026, a reset email from the live app arrived in Gmail. Its link reset a temporary account's password, the new password allowed login, and reusing the link returned HTTP 422. The temporary account was removed. Repeat this check after changing the sender, app origin, credentials, or email provider.

## Reminders

SMS stays disabled on the web service. Follow the [free reminder scheduler setup](../README.md#free-reminder-scheduler) to configure GitHub Actions against the same database. The free web service cannot keep a worker running while asleep.

Twilio is separate from hosting and may charge for numbers and messages. Keep delivery disabled until credentials, recipient consent, and spending limits are configured. Never put credentials in this repository or a PR.

## Recovery and monitoring

Use /health/ready for Render's health check and review failed deploys in its dashboard. That endpoint checks the database without returning private connection details. Monitoring that keeps waking the app can consume the workspace's free hours.

Neon's free restore history is limited to six hours and up to 1 GB of changes. It is not a replacement for an independent backup. Follow the [encrypted backup and restore guide](backups.md) before enabling the optional backup schedule. Never upload a plain database dump to a public repository or Actions artifact.

See [operations alerts](monitoring.md) for failed and overdue workflow checks. GitHub issue assignment uses your account's notification preferences. It does not guarantee email delivery or detect an outage of GitHub itself.

See [launch status](launch-status.md) for live checks and remaining setup. Keep SMS disabled until an approved test text arrives and the scheduled sender has been verified.

## Provider documentation

[Render free limits](https://render.com/docs/free)

[Neon free limits and restore history](https://neon.com/docs/introduction/plans)

[Brevo SMTP settings](https://developers.brevo.com/docs/smtp-integration)

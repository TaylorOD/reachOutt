# Launch status

Initial checks were completed November 6, 2026, with email reminders checked November 14. ReachOutt is a small beta on free Render hosting with Neon PostgreSQL. This is a dated verification record, not a promise of continuous availability.

## Verified

1. The public app and database health check respond successfully.
2. Password reset email arrives in Gmail. The received link works, the new password allows login, and the used link is rejected.
3. A fictional contact, paused future reminder, schedule and existing login survived a Render service restart. Before and after API responses matched.
4. A fresh encrypted Neon backup restored into a separate local PostgreSQL database. Users, contacts, reminders and schema migrations matched, including the fictional paused reminder.
5. The homepage animation was checked on desktop and mobile. The latest application PR passed frontend, Rails, browser, preview and security checks.
6. Daily encrypted GitHub backups are enabled after owner approval. The first [backup run](https://github.com/TaylorOD/reachOutt/actions/runs/42295355480) succeeded. Its downloaded artifact decrypted and restored into a separate local database with matching users, contacts, reminders and migrations.
7. The operations monitor passed after the backup. Its earlier test created an issue assigned to the owner and produced a GitHub assignment notification.
8. The [email reminder worker](https://github.com/TaylorOD/reachOutt/actions/runs/43668706680) sent a fictional reminder through Brevo to the approved test inbox. Gmail received it, and its next send date advanced by the configured interval. The temporary account, contact, and reminder were removed. Automatic email reminders are enabled. SMS remains optional and disabled.
9. All eight daily scheduled backups from November 7 through November 14 succeeded, including [the latest run](https://github.com/TaylorOD/reachOutt/actions/runs/43609670135).

## Come back to

1. Confirm GitHub alert delivery to the owner's preferred inbox. An independent monitor would be needed to detect an outage of GitHub itself.
2. Save the backup recovery passphrase in the owner's password manager. It must remain available independently of the repository and hosting account.

Free hosting can sleep and scheduled reminders can be delayed. Email uses the existing Brevo setup and its sending allowance. No SMS is needed for email reminders.

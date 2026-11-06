# Launch status

Checked November 6, 2026. ReachOutt is a small beta on free Render hosting with Neon PostgreSQL. This is a dated verification record, not a promise of continuous availability.

## Verified

1. The public app and database health check respond successfully.
2. Password reset email arrives in Gmail. The received link works, the new password allows login, and the used link is rejected.
3. A fictional contact, paused future reminder, schedule and existing login survived a Render service restart. Before and after API responses matched.
4. A fresh encrypted Neon backup restored into a separate local PostgreSQL database. Users, contacts, reminders and schema migrations matched, including the fictional paused reminder.
5. The homepage animation was checked on desktop and mobile. The latest application PR passed frontend, Rails, browser, preview and security checks.

## Come back to

1. Twilio has no active sending number. Choose the appropriate number and registration path, approve a budget and recipient, then connect the credentials to the protected GitHub production environment. Confirm delivery to the approved recipient before enabling the reminder schedule.
2. Daily backups remain off until the owner approves storing encrypted backup artifacts in the public repository and saving the backup credentials in GitHub. After approval, run a backup manually, download and restore that artifact, then rely on the daily schedule.
3. Confirm GitHub alert delivery to the owner's preferred inbox. An independent monitor would be needed to detect an outage of GitHub itself.
4. Save the backup recovery passphrase in the owner's password manager. It must remain available independently of the repository and hosting account.

Free hosting can sleep and scheduled reminders can be delayed. Twilio messaging and sender registration may cost money even when hosting is free. No sending number was purchased and no SMS was sent during these checks.

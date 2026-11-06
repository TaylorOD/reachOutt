# Database backups

The Database backup workflow makes a daily PostgreSQL export, encrypts it with GnuPG AES256, and keeps the encrypted artifact for seven days. It starts disabled. A failed dump or encryption step prevents upload. No plain dump is uploaded.

## Setup

1. Create a random passphrase with at least 32 characters. Save it in your password manager with the app name and date. Losing it means losing access to these backups.
2. Add it as BACKUP_PASSPHRASE in the GitHub production environment. That environment must allow only main. Add Neon's direct connection as DATABASE_URL_UNPOOLED, with TLS. Existing setups may use a direct DATABASE_URL instead.
3. Set the repository variable BACKUPS_ENABLED to true. Run Database backup manually and download its artifact.
4. Perform the restore check below before relying on the schedule. Enable Actions failure notifications and check backup dates regularly.

These artifacts are in a public repository. Anyone able to download one gets encrypted database contents, so the passphrase must be strong and kept separately. Do not enable this storage location unless that is acceptable. Keep a private downloaded copy for recovery beyond seven days.

GitHub schedules can be late or missed and stop after 60 days of repository inactivity. Artifact storage also has limits. Watch total usage and keep backup sizes within the free allowance. Neon's short restore history helps between exports but does not replace independent backups.

## Local export

Install PostgreSQL 18 client tools and GnuPG. In a private terminal, set DATABASE_URL_UNPOOLED and BACKUP_PASSPHRASE without saving them in shell history. The script prefers DATABASE_URL_UNPOOLED and falls back to DATABASE_URL. Then run:

```sh
bash bin/database-backup reachoutt.dump.gpg
```

The script refuses to overwrite an existing file and removes its temporary plain dump on exit.

## Restore check

Use an empty, disposable PostgreSQL database. Never point this check at the live database. Disable SMS and email in the app used for the check.

Decrypt locally into a private directory. GnuPG will ask for the backup passphrase:

```sh
gpg --output reachoutt.dump --decrypt reachoutt.dump.gpg
pg_restore --list reachoutt.dump
```

Set PGDATABASE, PGHOST, PGPORT, PGUSER, and PGPASSWORD for the empty test database, then restore:

```sh
pg_restore --exit-on-error --no-owner --no-acl --dbname="$PGDATABASE" reachoutt.dump
```

Check row counts for users, contacts, and reachouts. Start a disposable app against the restored database with delivery disabled. Confirm contacts, pause status, and next reminder times are intact. Remove the decrypted file when done.

Record the backup date, restore date, and result somewhere private. Test again after database schema changes. A successful export alone does not prove recovery works.

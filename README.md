## ReachOutt README:

### ReachOutt:

- ReachOutt was build out of my frustration with not keeping in touch with friends and family that I care about. I often found myself going weeks without speaking to them. I developed ReachOutt as an automated system to remind me to keep in tough.
- After signing up users can create contacts, people they would like to keep in touch with, and set reachouts, reminders to reach out to them, on whatever schedule they would like.
- It utilizes several API's to send automated reminder texts and ideas of what to reach out about.
- ReachOutt uses Twilio for texting reminders to reachout
- You can find it online at: Reachoutt.com

### Technology stack:

| Tech | What it does |
| --- | --- |
| Ruby on Rails | The API |
| Vue.js and Bootstrap | The front end |
| PostgreSQL | The database |
| Twilio | Sends the reminder texts |
| PostgreSQL schedule | Keeps reminders across restarts |
| News API and JokeAPI | Ideas for what to reach out about |
| bcrypt and JWT | Passwords and logins |
| Heroku | Hosting |

### Status:

- Beta.

### Running this app:

Use Ruby 4.0.7, Node 24.15 or newer, and PostgreSQL 18. Copy `.env.example` to `.env` and set your local database connection.

```sh
bundle install
bundle exec rails db:prepare
bundle exec rails server
```

In another terminal, run `npm ci` and `npm run serve`. Open `http://127.0.0.1:8080/app/`. The dev server forwards API requests to Rails on port 3000.

For the production build, run `npm run build` and open Rails at `http://127.0.0.1:3000`. Build output goes to `public/app`. Set `RAILS_SERVE_STATIC_FILES=true` in production unless your web server serves that directory.

Run backend tests with `RAILS_ENV=test bundle exec rails db:prepare` and `bundle exec rails test`. On PowerShell, set `$env:RAILS_ENV='test'` before preparing the test database.

The app does not need the original encrypted credentials for local login. Production needs a PostgreSQL `DATABASE_URL` and a stable `SECRET_KEY_BASE`. Generate a secret with `bundle exec rails secret`. Keep an existing production secret when upgrading so current login tokens keep working.

Optional demo data is fictional. Set `SEED_DEMO=true` and run `bundle exec rails db:seed` in development. The demo login is `alex@example.test` with password `local demo password`.

### Sending reminders

Run `bundle exec rails reminders:work` as a separate worker process. It checks schedules every minute. You can also run `bundle exec rails reminders:send` from an external scheduler. It reads due reminders from PostgreSQL. Start dates use UTC. Edits replace the schedule, and deleting a contact removes its reminders.

SMS is off by default. To enable it, set `SMS_ENABLED=true`, `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, and `TWILIO_FROM_NUMBER`. News and sports suggestions also need `NEWS_API_KEY`. Failed suggestions do not block the reminder.

The migration preserves existing records. Valid old schedules become due at their start date or the migration time, whichever is later. Invalid old schedules stay paused until edited. Review existing reminders before enabling SMS.

Concurrent workers use row locks. Failed sends stay due for retry. A crash after Twilio accepts a message but before the database commits can still result in a duplicate on retry. Check Twilio delivery logs before manually retrying an uncertain send.

### Frontend tests

Run `npm test` for form tests. For browser tests, run `npm run build`, start Rails with SMS disabled, install Chromium with `npx playwright install chromium`, then run `npm run test:e2e`. Browser tests create fictional accounts in the database used by that server. Use a local or disposable database.

## Screenshots:

- ![Home Page](/frontend/public/assets/images/ReachOutt_Home_screenshot.png 'Home Page')
- ![About Page](/frontend/public/assets/images/ReachOutt_About_screenshot.png 'About Page')
- ![Reachouts Page](/frontend/public/assets/images/ReachOutt_Reachout_screenshot.png 'Reachouts Page')

### Contributing

- Contributor Guidelines: Feel free to contribute or fork this project.
- Code Style/Requirements: If you are going to contribute please use rails, javascript, or vue.

### Contact

- dorsetttaylordev@gmail.com

---

## Credits and references

1. Projects that inspired me: A terrible google calendar system I built years ago that resulted in me constantly putting off calendar reminders.
2. Reminders use a database schedule and a recurring task.

### Password reset email

Development writes reset emails to `tmp/mail`. Production needs a trusted HTTPS `APP_URL`, a verified `MAIL_FROM`, and your provider settings in `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_USERNAME`, and `SMTP_PASSWORD`. Reset links expire after 15 minutes. A completed reset signs out existing sessions. Email delivery must be configured and tested with your provider before offering resets to users.

Reminders can be paused without deleting them. Resuming waits one full reminder interval, or until a future start date. Missed reminders are not sent in a burst. A message already being sent cannot be recalled.

### Heroku setup

The Procfile runs database migrations during release and defines separate web and reminder processes. Configure the Node.js buildpack before Ruby so the Vue build is included. The app still uses Vue 3, Vue Router 5, and Vite 8.

Keep your existing PostgreSQL database and stable `SECRET_KEY_BASE`. Configure `DATABASE_URL` and `RAILS_SERVE_STATIC_FILES=true`. Enable one worker with `heroku ps:scale worker=1 --app YOUR_APP` after checking your plan and costs. Creating a Procfile alone does not enable a worker.

Schedules and pause status live in PostgreSQL. A restarted worker resumes from those records instead of losing timers. The worker still needs to be running for messages to go out. Set the SMS and email settings above only when you are ready to enable delivery. This repository does not provision hosting or send a test text automatically.

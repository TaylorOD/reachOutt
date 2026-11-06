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
| rufus-scheduler | Times the reminders |
| News API and JokeAPI | Ideas for what to reach out about |
| bcrypt and JWT | Passwords and logins |
| Heroku | Hosting |

### Status:

- Beta.

### Running this app:

Use Ruby 4.0.7, Node 24 or newer, and PostgreSQL 18. Copy `.env.example` to `.env` and set your local database connection.

```sh
bundle install
bundle exec rails db:prepare
bundle exec rails server
```

In another terminal, run `npm ci` and `npm run serve`.

Run backend tests with `RAILS_ENV=test bundle exec rails db:prepare` and `bundle exec rails test`. On PowerShell, set `$env:RAILS_ENV='test'` before preparing the test database.

The app does not need the original encrypted credentials for local login. Production needs a PostgreSQL `DATABASE_URL` and a stable `SECRET_KEY_BASE`. Generate a secret with `bundle exec rails secret`. Keep an existing production secret when upgrading so current login tokens keep working.

Optional demo data is fictional. Set `SEED_DEMO=true` and run `bundle exec rails db:seed` in development. The demo login is `alex@example.test` with password `local demo password`.

## Screenshots:

- ![Home Page](/frontend/public/assets/images/ReachOutt_Home_screenshot.png 'Home Page')
- ![About Page](/frontend/public/assets/images/ReachOutt_About_screenshot.png 'About Page')
- ![Reachouts Page](/frontend/public/assets/images/ReachOutt_Reachout_screenshot.png 'Reachouts Page')

### Contributing

- Contributor Guidelines: Feel free to contribute or fork this project.
- Code Style/Requirements: If you are going to contribute please use rails, javascript, or vue.

### Known issues

- reachouts don't persist after a certain period of time on heroku

### TODO

Small:

- Create User Account Page
- Fix reachout not persisting bug

Medium:

- Remove Ability to change contact name on reachout page
- Create Password Reset Function
- Add Ability to turn ReachOuts off

Big:

- Rebuild front end with react

### Contact

- dorsetttaylordev@gmail.com

---

## Open source licensing info

1. [TERMS](TERMS.md)
2. [LICENSE](LICENSE)
3. [CFPB Source Code Policy](https://github.com/cfpb/source-code-policy/)

---

## Credits and references

1. Projects that inspired me: A terrible google calendar system I built years ago that resulted in me constantly putting off calendar reminders.
2. I use Rufus-Scheduler for my reminders. It's a simple version of a cron job.

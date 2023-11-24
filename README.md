## ReachOutt README:

### ReachOutt:

- ReachOutt was build out of my frustration with not keeping in touch with friends and family that I care about. I often found myself going weeks without speaking to them. I developed ReachOutt as an automated system to remind me to keep in tough.
- After signing up users can create contacts, people they would like to keep in touch with, and set reachouts, reminders to reach out to them, on whatever schedule they would like.
- It utilizes several API's to send automated reminder texts and ideas of what to reach out about.
- ReachOutt uses Twilio for texting reminders to reachout
- You can find it online at: Reachoutt.com

### Technology stack:

- Built using Ruby on Rails, Vue.js, Vue Native, JavaScript, HTML, CSS, tailwinds, and several API's.

### Status:

- Beta.

### Running this app:

backend:

- Setup: `bundle install`
- `bin/rails s`

front end:

- Setup: `npm install`
- `npm run serve`

You can also build the front end pages and have the backend page serve them using: `npm run build`
This allows you to work without having a front end server running but you will not get any
front end hot reloads or updates.

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

- Fix reachout not persisting bug - 3 points
- General ui cleanup (using tailwinds) - 3 points
- Sign up page validation and error messaging - 2 points
- Contact page data validation - 2 point
- Error and success messaging being the same box rather than two - 1 point
- Remove any capstone language and ensure no errors caused by it - 2 points
- Prevent non logged in users from contact and reachout pages - 2 points
- Add more data to db:seeds and ensure it runs on build - 2 points

Medium:

- Remove Ability to change contact name on reachout page - 2 points
- Create Password Reset Function - 3 points
- Add Ability to turn ReachOuts off - 3 points
- Log users in directly from sign up page - 2 points
- Create User Account Page - 3 points +

Big:

- Rebuild front end with react - 5 points
- Research other ways of running scheduled jobs - 3 point spike
- Optimize for mobile - 5 points

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

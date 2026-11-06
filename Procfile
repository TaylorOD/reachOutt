release: bundle exec ruby bin/migrate
web: bundle exec puma -C config/puma.rb
worker: bundle exec rails reminders:work

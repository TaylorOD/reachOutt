namespace :reminders do
  desc 'Send due reminders once. Schedule this task every minute.'
  task send: :environment do
    ReminderDispatcher.call if ReminderDelivery.enabled?
  end
end

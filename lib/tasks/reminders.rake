namespace :reminders do
  desc 'Keep checking persisted schedules until the worker shuts down.'
  task work: :environment do
    worker = ReminderWorker.new
    %w[TERM INT].each { |signal| Signal.trap(signal) { worker.stop } }
    worker.run
  end

  desc 'Send due reminders once. Schedule this task every minute.'
  task send: :environment do
    ReminderDispatcher.call if ReminderDelivery.enabled?
  end
end

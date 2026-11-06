class ReminderWorker
  def initialize(dispatcher: -> { ReminderDispatcher.call if ReminderDelivery.enabled? }, sleeper: ->(seconds) { sleep(seconds) }, interval: 60)
    @dispatcher = dispatcher
    @sleeper = sleeper
    @interval = interval
    @stopping = false
  end

  def stop
    @stopping = true
  end

  def run
    until @stopping
      begin
        Rails.application.executor.wrap { @dispatcher.call }
      rescue StandardError => error
        Rails.logger.error("Reminder worker failed: #{error.class}")
      end
      @interval.times do
        break if @stopping
        @sleeper.call(1)
      end
    end
  end
end

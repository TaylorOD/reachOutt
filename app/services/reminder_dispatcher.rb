class ReminderDispatcher
  def self.call(now: Time.current, delivery: ReminderDelivery)
    Reachout.where('next_send_at <= ?', now).find_each do |reachout|
      # A second worker waits, reloads, and sees the updated schedule.
      reachout.with_lock do
        next if reachout.next_send_at.nil? || reachout.next_send_at > now
        next unless reachout.valid?
        next unless delivery.call(reachout)

        reachout.update!(last_reachout_sent: now.to_date, next_send_at: now + reachout.interval)
      end
    rescue ActiveRecord::RecordNotFound
      # The owner deleted this reminder while the worker was reading it.
      next
    rescue StandardError => error
      Rails.logger.error("Reminder #{reachout.id} failed: #{error.class}")
    end
  end
end

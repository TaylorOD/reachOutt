class ReminderDelivery
  def self.enabled?
    case ENV.fetch('REMINDER_CHANNEL', 'email')
    when 'email' then true
    when 'sms' then ENV['SMS_ENABLED'] == 'true'
    else raise ArgumentError, 'REMINDER_CHANNEL must be email or sms'
    end
  end

  def self.call(reachout)
    return false unless enabled?

    if ENV.fetch('REMINDER_CHANNEL', 'email') == 'email'
      ReminderMailer.reminder(reachout).deliver_now
      return true
    end

    allowed = ENV.fetch('SMS_ALLOWED_RECIPIENTS', '').split(',').map(&:strip)
    unless allowed.include?(reachout.user.phone_number)
      raise ArgumentError, 'SMS recipient has not been approved'
    end

    client = Twilio::REST::Client.new(
      ENV.fetch('TWILIO_ACCOUNT_SID'), ENV.fetch('TWILIO_AUTH_TOKEN'),
      nil, nil, Twilio::HTTP::Client.new(timeout: 10)
    )
    body = "Hey #{reachout.user.first_name}! Time to reach out to #{reachout.contact.first_name} #{reachout.contact.last_name} at #{reachout.contact.phone_number}."
    suggestion = reachout.get_topic_data
    body += " #{suggestion}" if suggestion.present?
    client.messages.create(from: ENV.fetch('TWILIO_FROM_NUMBER'), to: reachout.user.phone_number, body: body)
    true
  end
end

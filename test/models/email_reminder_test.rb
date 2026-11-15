require 'test_helper'
require 'minitest/mock'

class EmailReminderTest < ActiveSupport::TestCase
  setup do
    @previous = ENV.to_h.slice('REMINDER_CHANNEL', 'SMS_ENABLED')
    ENV.delete('REMINDER_CHANNEL')
    ENV['SMS_ENABLED'] = 'false'
    ActionMailer::Base.deliveries.clear
    user = create_user
    contact = user.contacts.create!(first_name: 'Sam', last_name: 'Friend', phone_number: '+15005550007')
    @reminder = user.reachouts.create!(contact: contact, frequency: '7d', start_date: Date.current.iso8601)
    @now = 1.minute.from_now.change(usec: 0)
  end

  teardown do
    %w[REMINDER_CHANNEL SMS_ENABLED].each { |key| ENV[key] = @previous[key] }
    ActionMailer::Base.deliveries.clear
  end

  test 'email is the default and advances the schedule only once without Twilio' do
    Twilio::REST::Client.stub(:new, ->(*) { flunk 'email delivery called Twilio' }) do
      ReminderDispatcher.call(now: @now)
      ReminderDispatcher.call(now: @now)
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    mail = ActionMailer::Base.deliveries.first
    assert_equal [@reminder.user.email], mail.to
    assert_equal 'Time to reach out to Sam Friend', mail.subject
    assert_includes mail.body.decoded, 'Hey Alex!'
    assert_includes mail.body.decoded, '+15005550007'
    assert_includes mail.body.decoded, 'pause or change'
    assert_equal @now + 7.days, @reminder.reload.next_send_at
    assert_equal @now.to_date, @reminder.last_reachout_sent
  end

  test 'mail failures leave the reminder due and report a failed run' do
    due = @reminder.next_send_at
    delivery = Object.new
    def delivery.deliver_now
      raise Net::SMTPFatalError, 'rejected'
    end
    ReminderMailer.stub(:reminder, delivery) do
      assert_raises(ReminderDispatcher::DeliveryError) { ReminderDispatcher.call(now: @now) }
    end
    assert_equal due, @reminder.reload.next_send_at
    assert_nil @reminder.last_reachout_sent
    assert_empty ActionMailer::Base.deliveries
  end

  test 'paused and future reminders send no email' do
    @reminder.update!(enabled: false)
    ReminderDispatcher.call(now: @now)
    @reminder.update!(enabled: true, start_date: 1.month.from_now.to_date.iso8601)
    ReminderDispatcher.call(now: @now)
    assert_empty ActionMailer::Base.deliveries
  end

  test 'disabled SMS does not fall back to email or mark a reminder sent' do
    ENV['REMINDER_CHANNEL'] = 'sms'
    ReminderDispatcher.call(now: @now)
    assert_empty ActionMailer::Base.deliveries
    assert_nil @reminder.reload.last_reachout_sent
  end

  test 'unknown channels fail instead of silently reporting success' do
    ENV['REMINDER_CHANNEL'] = 'typo'
    assert_raises(ArgumentError) { ReminderDelivery.enabled? }
  end

  test 'email includes optional conversation suggestions' do
    @reminder.stub(:get_topic_data, 'Ask about their weekend.') do
      assert_includes ReminderMailer.reminder(@reminder).body.decoded, 'Ask about their weekend.'
    end
  end
end

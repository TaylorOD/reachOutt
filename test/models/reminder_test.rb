require 'test_helper'

class ReminderTest < ActiveSupport::TestCase
  setup do
    @user = create_user
    @contact = @user.contacts.create!(first_name: 'Sam')
    @reachout = @user.reachouts.create!(contact: @contact, frequency: '7d', start_date: Date.current.iso8601)
  end

  test 'a fresh worker reads the persisted schedule and only sends once' do
    sent = []
    sender = ->(record) { sent << record.id; true }
    now = 1.minute.from_now.change(usec: 0)
    ReminderDispatcher.call(now: now, delivery: sender)
    ReminderDispatcher.call(now: now, delivery: sender)
    assert_equal [@reachout.id], sent
    assert_equal now + 7.days, @reachout.reload.next_send_at
    assert_equal now.to_date, @reachout.last_reachout_sent
  end

  test 'future reminders wait and disabled delivery preserves the due date' do
    @reachout.update!(start_date: 1.week.from_now.to_date.iso8601)
    sender = ->(_) { flunk 'future reminder sent' }
    ReminderDispatcher.call(delivery: sender)
    @reachout.update!(start_date: Date.current.iso8601)
    due = @reachout.next_send_at
    ReminderDispatcher.call(now: 1.minute.from_now, delivery: ->(_) { false })
    assert_equal due, @reachout.reload.next_send_at
    assert_nil @reachout.last_reachout_sent
  end

  test 'failed delivery retries later without preventing other reminders' do
    other = @user.reachouts.create!(contact: @contact, frequency: '1d', start_date: Date.current.iso8601)
    sender = ->(record) { raise IOError if record.id == @reachout.id; true }
    error = assert_raises(ReminderDispatcher::DeliveryError) do
      ReminderDispatcher.call(now: 1.minute.from_now, delivery: sender)
    end
    assert_equal "1 reminder deliveries failed", error.message
    assert_nil @reachout.reload.last_reachout_sent
    assert other.reload.last_reachout_sent
  end

  test 'updates replace the schedule and deletion stops delivery' do
    @reachout.update!(frequency: '1d', start_date: Date.tomorrow.iso8601)
    assert_equal Date.tomorrow.in_time_zone, @reachout.reload.next_send_at
    @contact.destroy!
    assert_not Reachout.exists?(@reachout.id)
    ReminderDispatcher.call(now: 1.month.from_now, delivery: ->(_) { flunk 'deleted reminder sent' })
  end

  test 'invalid frequencies dates and foreign contacts are rejected' do
    @reachout.frequency = '1s'
    assert_not @reachout.valid?
    @reachout.frequency = '1d'
    @reachout.start_date = 'not a date'
    assert_not @reachout.valid?
    @reachout.start_date = Date.current.iso8601
    @reachout.contact = create_user(email: 'other@example.com').contacts.create!(first_name: 'Other')
    assert_not @reachout.valid?
  end

  test 'creating and updating reminders never sends SMS from the request' do
    assert_difference 'Reachout.count', 1 do
      @user.reachouts.create!(contact: @contact, frequency: '1d', start_date: Date.current.iso8601)
    end
    assert @reachout.update(topic: 'News')
  end
end

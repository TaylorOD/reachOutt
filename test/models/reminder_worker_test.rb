require 'test_helper'

class ReminderWorkerTest < ActiveSupport::TestCase
  test 'new worker instances resume database schedules without repeating a send' do
    user = create_user
    reminder = user.reachouts.create!(contact: user.contacts.create!(first_name: 'Sam'), frequency: '7d', start_date: Date.current.iso8601)
    sent = []
    now = 1.minute.from_now
    dispatcher = -> { ReminderDispatcher.call(now: now, delivery: ->(record) { sent << record.id; true }) }
    2.times do
      worker = nil
      worker = ReminderWorker.new(dispatcher: dispatcher, sleeper: ->(_) { worker.stop })
      worker.run
    end
    assert_equal [reminder.id], sent
    assert_in_delta (now + 7.days).to_f, reminder.reload.next_send_at.to_f, 0.001
  end

  test 'a transient failure retries and shutdown interrupts the polling wait' do
    attempts = 0
    sleeps = 0
    worker = nil
    worker = ReminderWorker.new(interval: 1,
      dispatcher: -> { attempts += 1; raise IOError if attempts == 1 },
      sleeper: ->(_) { sleeps += 1; worker.stop if sleeps == 2 })
    worker.run
    assert_equal 2, attempts
    assert_equal 2, sleeps
  end

  test 'stopped workers do not dispatch' do
    worker = ReminderWorker.new(dispatcher: -> { flunk 'stopped worker dispatched' })
    worker.stop
    assert_nil worker.run
  end
end

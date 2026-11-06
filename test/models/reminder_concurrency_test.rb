require 'test_helper'
require 'timeout'

class ReminderConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test 'two workers cannot deliver the same due reminder together' do
    user = create_user(email: 'concurrency@example.test')
    contact = user.contacts.create!(first_name: 'Sam')
    reminder = user.reachouts.create!(contact: contact, frequency: '1d', start_date: Date.current.iso8601)
    entered = Queue.new
    release = Queue.new
    sent = Queue.new
    now = 1.minute.from_now
    sender = ->(record) do
      sent << record.id
      entered << true
      release.pop
      true
    end
    first = Thread.new { Rails.application.executor.wrap { ReminderDispatcher.call(now: now, delivery: sender) } }
    Timeout.timeout(5) { entered.pop }
    second = Thread.new { Rails.application.executor.wrap { ReminderDispatcher.call(now: now, delivery: sender) } }
    release << true
    # A second permit prevents a broken implementation from hanging the test.
    release << true
    Timeout.timeout(5) { first.value; second.value }
    assert_equal 1, sent.size
    assert_equal reminder.id, sent.pop
  ensure
    first&.kill if first&.alive?
    second&.kill if second&.alive?
    reminder&.destroy!
    contact&.destroy!
    user&.destroy!
  end
end

require 'test_helper'

class ReminderControlsTest < ActionDispatch::IntegrationTest
  test 'only the owner can pause and resume a persisted reminder' do
    user = create_user
    contact = user.contacts.create!(first_name: 'Sam')
    reminder = user.reachouts.create!(contact: contact, frequency: '7d', start_date: Date.current.iso8601)
    other = create_user(email: 'other@example.test')
    patch "/api/reachouts/#{reminder.id}", params: { enabled: false }, headers: auth_headers(other), as: :json
    assert_response :not_found
    assert reminder.reload.enabled?
    patch "/api/reachouts/#{reminder.id}", params: { enabled: 'false' }, headers: auth_headers(user), as: :json
    assert_response :bad_request
    patch "/api/reachouts/#{reminder.id}", params: { enabled: false }, headers: auth_headers(user), as: :json
    assert_response :success
    assert_equal false, response.parsed_body['enabled']
    assert_not reminder.reload.enabled?
    ReminderDispatcher.call(now: 1.month.from_now, delivery: ->(_) { flunk 'paused reminder sent' })
    travel_to Time.current.change(usec: 0) do
      patch "/api/reachouts/#{reminder.id}", params: { enabled: true }, headers: auth_headers(user), as: :json
      assert_response :success
      assert reminder.reload.enabled?
      assert_equal 7.days.from_now, reminder.next_send_at
      ReminderDispatcher.call(delivery: ->(_) { flunk 'resumed reminder sent too soon' })
    end
  end
end

require 'test_helper'

class ReminderContactTest < ActionDispatch::IntegrationTest
  test 'a reminder retains its contact while schedule and topic remain editable' do
    user = create_user
    contact = user.contacts.create!(first_name: 'Sam')
    other = user.contacts.create!(first_name: 'Alex')
    reminder = user.reachouts.create!(contact: contact, frequency: '7d', start_date: Date.current.iso8601)
    headers = auth_headers(user)
    patch "/api/reachouts/#{reminder.id}", params: { contact_id: other.id, frequency: '1d' }, headers: headers, as: :json
    assert_response :unprocessable_entity
    assert_equal contact.id, reminder.reload.contact_id
    assert_equal '7d', reminder.frequency
    patch "/api/reachouts/#{reminder.id}", params: { contact_id: contact.id, frequency: '1d', first_name: 'Changed' }, headers: headers, as: :json
    assert_response :success
    assert_equal '1d', reminder.reload.frequency
    assert_equal 'Sam', contact.reload.first_name
  end
end

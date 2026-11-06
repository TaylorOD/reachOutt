require 'test_helper'

class ReachoutsTest < ActionDispatch::IntegrationTest
  test 'reminder lifecycle and ownership use the real database' do
    user = create_user
    contact = user.contacts.create!(first_name: 'Sam')
    other = create_user(email: 'other@example.com')
    foreign = other.contacts.create!(first_name: 'Other')
    headers = auth_headers(user)
    params = { contact_id: contact.id, frequency: '7d', start_date: Date.current.iso8601, topic: 'News' }
    post '/api/reachouts', params: params.merge(contact_id: foreign.id), headers: headers, as: :json
    assert_response :not_found
    post '/api/reachouts', params: params.merge(frequency: '1s'), headers: headers, as: :json
    assert_response :bad_request
    post '/api/reachouts', params: params, headers: headers, as: :json
    assert_response :success
    id = response.parsed_body['id']
    get '/api/reachouts', headers: auth_headers(other)
    assert_equal [], response.parsed_body
    get "/api/reachouts/#{id}", headers: auth_headers(other)
    assert_response :not_found
    patch "/api/reachouts/#{id}", params: { frequency: '1d' }, headers: auth_headers(other), as: :json
    assert_response :not_found
    delete "/api/reachouts/#{id}", headers: auth_headers(other)
    assert_response :not_found
    patch "/api/reachouts/#{id}", params: { contact_id: foreign.id }, headers: headers, as: :json
    assert_response :not_found
    patch "/api/reachouts/#{id}", params: { topic: 'Sports', frequency: '1d' }, headers: headers, as: :json
    assert_response :success
    assert_equal 'Sports', response.parsed_body['topic']
    delete "/api/reachouts/#{id}", headers: headers
    assert_response :success
    assert_not Reachout.exists?(id)
  end
end

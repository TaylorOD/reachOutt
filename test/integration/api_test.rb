require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
  test 'signup and login work without legacy credentials' do
    post '/api/users', params: { email: 'new@example.com', password: 'test password', password_confirmation: 'test password' }, as: :json
    assert_response :created
    post '/api/sessions', params: { email: 'new@example.com', password: 'test password' }, as: :json
    assert_response :created
    assert response.parsed_body['jwt'].present?
    post '/api/sessions', params: { email: 'new@example.com', password: 'wrong' }, as: :json
    assert_response :unauthorized
  end

  test 'invalid and expired tokens return unauthorized' do
    ['garbage', JWT.encode({ user_id: 1, exp: 1.hour.ago.to_i }, Rails.application.secret_key_base, 'HS256')].each do |token|
      get '/api/contacts', headers: { 'Authorization' => "Bearer #{token}" }
      assert_response :unauthorized
    end
  end

  test 'contacts can be created edited and deleted only by their owner' do
    user = create_user
    other = create_user(email: 'other@example.com')
    post '/api/contacts', params: { first_name: 'Sam', last_name: 'Example' }, headers: auth_headers(user), as: :json
    assert_response :success
    id = response.parsed_body['id']
    get "/api/contacts/#{id}", headers: auth_headers(other)
    assert_response :not_found
    patch "/api/contacts/#{id}", params: { first_name: 'Changed' }, headers: auth_headers(other), as: :json
    assert_response :not_found
    delete "/api/contacts/#{id}", headers: auth_headers(other)
    assert_response :not_found
    patch "/api/contacts/#{id}", params: { first_name: 'Updated' }, headers: auth_headers(user), as: :json
    assert_response :success
    assert_equal 'Updated', response.parsed_body['first_name']
    delete "/api/contacts/#{id}", headers: auth_headers(user)
    assert_response :success
    assert_not Contact.exists?(id)
  end

  test 'Twilio callback routes to signature verification' do
    post '/api/twilio/status', params: { MessageStatus: 'delivered' }
    assert_response :forbidden
  end

  test 'health check boots without external services' do
    get '/up'
    assert_response :success
  end
end

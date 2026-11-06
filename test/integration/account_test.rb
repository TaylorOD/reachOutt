require 'test_helper'

class AccountTest < ActionDispatch::IntegrationTest
  test 'account requires login and only returns safe fields for the signed in user' do
    get '/api/account'
    assert_response :unauthorized
    user = create_user
    get '/api/account', headers: auth_headers(user)
    assert_response :success
    assert_equal user.id, response.parsed_body['id']
    assert_equal %w[email first_name id last_name phone_number], response.parsed_body.keys.sort
  end

  test 'profile updates cannot target another user or change a password' do
    user = create_user
    other = create_user(email: 'other@example.com')
    patch '/api/account', headers: auth_headers(user), params: { id: other.id, first_name: 'Updated', phone_number: '+15005550007', password: 'attacker password' }, as: :json
    assert_response :success
    assert_equal 'Updated', user.reload.first_name
    assert_equal 'Alex', other.reload.first_name
    assert user.authenticate('test password')
  end

  test 'email changes require the password and reject duplicate or invalid addresses' do
    user = create_user
    create_user(email: 'other@example.com')
    patch '/api/account', headers: auth_headers(user), params: { email: 'new@example.com' }, as: :json
    assert_response :unprocessable_entity
    patch '/api/account', headers: auth_headers(user), params: { email: 'other@example.com', current_password: 'test password' }, as: :json
    assert_response :unprocessable_entity
    patch '/api/account', headers: auth_headers(user), params: { email: 'invalid', current_password: 'test password' }, as: :json
    assert_response :unprocessable_entity
    patch '/api/account', headers: auth_headers(user), params: { email: ' NEW@example.com ', current_password: 'test password' }, as: :json
    assert_response :success
    assert_equal 'new@example.com', user.reload.email
    post '/api/sessions', params: { email: ' NEW@example.com ', password: 'test password' }, as: :json
    assert_response :created
  end
end

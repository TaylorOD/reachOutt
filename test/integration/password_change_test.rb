require 'test_helper'

class PasswordChangeTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user
    @headers = auth_headers(@user)
    @params = { current_password: 'test password', password: 'a new long password', password_confirmation: 'a new long password' }
  end

  test 'changing a password requires login and the current password' do
    patch '/api/account/password', params: @params, as: :json
    assert_response :unauthorized
    patch '/api/account/password', headers: @headers, params: @params.merge(current_password: 'wrong password'), as: :json
    assert_response :unprocessable_entity
    assert @user.reload.authenticate('test password')
    assert_equal 0, @user.session_version
  end

  test 'invalid new passwords leave the password and sessions unchanged' do
    [
      { password: 'short', password_confirmation: 'short' },
      { password_confirmation: 'different password' },
      { password: '', password_confirmation: '' },
      { password: 'a' * 73, password_confirmation: 'a' * 73 }
    ].each do |invalid|
      patch '/api/account/password', headers: @headers, params: @params.merge(invalid), as: :json
      assert_response :unprocessable_entity
      assert @user.reload.authenticate('test password')
      assert_equal 0, @user.session_version
    end
  end

  test 'changing a password revokes sessions and reset links without changing another account' do
    other = create_user(email: 'other@example.test')
    reset_token = @user.generate_token_for(:account_password_reset)
    patch '/api/account/password', headers: @headers, params: @params.merge(id: other.id), as: :json
    assert_response :success
    assert @user.reload.authenticate('a new long password')
    assert other.reload.authenticate('test password')
    assert_nil User.find_by_token_for(:account_password_reset, reset_token)
    get '/api/account', headers: @headers
    assert_response :unauthorized
    patch '/api/account/password', headers: @headers, params: @params, as: :json
    assert_response :unauthorized
    post '/api/sessions', params: { email: @user.email, password: 'test password' }, as: :json
    assert_response :unauthorized
    post '/api/sessions', params: { email: @user.email, password: 'a new long password' }, as: :json
    assert_response :created
    get '/api/account', headers: { Authorization: "Bearer #{response.parsed_body['jwt']}" }
    assert_response :success
  end
end

require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user
    ActionMailer::Base.deliveries.clear
  end

  test 'requests conceal account existence and limit repeated delivery' do
    post '/api/password_resets', params: { email: 'missing@example.test' }
    assert_response :accepted
    missing = response.parsed_body
    post '/api/password_resets', params: { email: @user.email.upcase }
    assert_response :accepted
    assert_equal missing, response.parsed_body
    assert_equal 1, ActionMailer::Base.deliveries.size
    mail = ActionMailer::Base.deliveries.last
    assert_equal [@user.email], mail.to
    assert_includes mail.body.to_s, '/reset-password#'
    post '/api/password_resets', params: { email: @user.email }
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test 'reset changes password revokes sessions and cannot be replayed' do
    headers = auth_headers(@user)
    token = @user.generate_token_for(:account_password_reset)
    patch '/api/password_resets', params: { token: token, password: 'a new long password', password_confirmation: 'a new long password' }
    assert_response :success
    assert @user.reload.authenticate('a new long password')
    get '/api/account', headers: headers
    assert_response :unauthorized
    patch '/api/password_resets', params: { token: token, password: 'a new long password', password_confirmation: 'a new long password' }
    assert_response :unprocessable_entity
    post '/api/sessions', params: { email: @user.email, password: 'a new long password' }
    assert_response :created
    get '/api/account', headers: { Authorization: "Bearer #{response.parsed_body['jwt']}" }
    assert_response :success
  end

  test 'expired tampered and invalid submissions cannot change password' do
    token = @user.generate_token_for(:account_password_reset)
    [token + 'tampered', ''].each do |bad|
      patch '/api/password_resets', params: { token: bad, password: 'a new long password', password_confirmation: 'a new long password' }
      assert_response :unprocessable_entity
    end
    patch '/api/password_resets', params: { token: token, password: 'short', password_confirmation: 'short' }
    assert_response :unprocessable_entity
    patch '/api/password_resets', params: { token: token, password: 'a new long password', password_confirmation: 'does not match' }
    assert_response :unprocessable_entity
    travel 16.minutes do
      patch '/api/password_resets', params: { token: token, password: 'a new long password', password_confirmation: 'a new long password' }
      assert_response :unprocessable_entity
    end
    assert @user.reload.authenticate('test password')
  end

  test 'email changes invalidate issued reset links' do
    token = @user.generate_token_for(:account_password_reset)
    @user.update!(email: 'new@example.test')
    assert_nil User.find_by_token_for(:account_password_reset, token)
  end

  test 'resetting to the same password still consumes the token' do
    token = @user.generate_token_for(:account_password_reset)
    patch '/api/password_resets', params: { token: token, password: 'test password', password_confirmation: 'test password' }
    assert_response :success
    assert_nil User.find_by_token_for(:account_password_reset, token)
  end
end

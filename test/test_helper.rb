ENV['RAILS_ENV'] = 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  def create_user(email: 'test@example.com')
    User.create!(email: email, password: 'test password', first_name: 'Alex', phone_number: '+15005550006')
  end

  def auth_headers(user)
    token = JWT.encode({ user_id: user.id, exp: 1.hour.from_now.to_i }, Rails.application.secret_key_base, 'HS256')
    { 'Authorization' => "Bearer #{token}" }
  end
end

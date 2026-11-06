class User < ApplicationRecord
  generates_token_for :account_password_reset, expires_in: 15.minutes do
    [session_version, Digest::SHA256.hexdigest(email)]
  end

  has_secure_password
  normalizes :email, with: ->(email) { email.strip.downcase }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  has_many :contacts
  has_many :reachouts
end

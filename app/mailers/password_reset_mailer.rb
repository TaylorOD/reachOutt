class PasswordResetMailer < ApplicationMailer
  def reset(user)
    origin = ENV.fetch("APP_URL", "http://localhost:3000")
    uri = URI.parse(origin)
    unless uri.host && uri.userinfo.nil? && uri.query.nil? && uri.fragment.nil? &&
        %w[http https].include?(uri.scheme) && (!Rails.env.production? || uri.scheme == "https")
      raise ArgumentError, "APP_URL must be a trusted HTTPS app URL in production"
    end
    token = user.generate_token_for(:account_password_reset)
    link = "#{origin.chomp('/')}/reset-password##{token}"
    body = <<~MESSAGE
      Use this link within 15 minutes to reset your password:

      #{link}

      If you did not request this, you can ignore this email.
    MESSAGE
    mail(
      to: user.email,
      from: ENV.fetch("MAIL_FROM", "reachoutt@example.test"),
      subject: "Reset your ReachOutt password",
      body: body,
      content_type: "text/plain"
    )
  end
end

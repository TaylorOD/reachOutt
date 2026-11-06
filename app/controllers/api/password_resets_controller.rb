class Api::PasswordResetsController < ApplicationController
  def create
    user = User.find_by("LOWER(email) = ?", params[:email].to_s.strip.downcase)
    if user
      user.with_lock do
        if !user.password_reset_sent_at || user.password_reset_sent_at < 1.minute.ago
          PasswordResetMailer.reset(user).deliver_now
          user.update_columns(password_reset_sent_at: Time.current)
        end
      end
    end
    render json: { message: "If an account matches, you will receive a reset link." }, status: :accepted
  rescue StandardError => error
    Rails.logger.error("Password reset delivery failed: #{error.class}")
    render json: { message: "If an account matches, you will receive a reset link." }, status: :accepted
  end

  def update
    user = User.find_by_token_for(:account_password_reset, params[:token].to_s)
    return invalid_link unless user

    user.with_lock do
      return invalid_link unless User.find_by_token_for(:account_password_reset, params[:token].to_s)&.id == user.id
      if params[:password].to_s.length < 12 || params[:password] != params[:password_confirmation]
        return render json: { errors: ["Use at least 12 characters and make sure both passwords match."] }, status: :unprocessable_entity
      end
      user.password = params[:password]
      user.password_confirmation = params[:password_confirmation]
      user.session_version += 1
      user.save!
    end
    render json: { message: "Password updated. Please log in again." }
  rescue ActiveRecord::RecordInvalid => error
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def invalid_link
    render json: { errors: ["This reset link is invalid or expired. Request a new link."] }, status: :unprocessable_entity
  end
end

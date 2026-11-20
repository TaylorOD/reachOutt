class Api::PasswordsController < ApplicationController
  before_action :authenticate_user

  def update
    user = current_user
    version = user.session_version
    user.with_lock do
      return head :unauthorized unless user.session_version == version
      unless user.authenticate(params[:current_password].to_s)
        return render json: { errors: ['Your current password is incorrect.'] }, status: :unprocessable_entity
      end

      password = params[:password]
      unless password.is_a?(String) && password.length >= 12 && password == params[:password_confirmation]
        return render json: { errors: ['Use at least 12 characters and make sure both passwords match.'] }, status: :unprocessable_entity
      end

      user.password = password
      user.password_confirmation = params[:password_confirmation]
      user.session_version += 1
      user.save!
    end
    render json: { message: 'Password changed. Log in with your new password.' }
  rescue ActiveRecord::RecordInvalid => error
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
  end
end

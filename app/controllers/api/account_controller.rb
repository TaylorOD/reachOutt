class Api::AccountController < ApplicationController
  before_action :authenticate_user

  def show
    render json: profile(current_user)
  end

  def update
    user = current_user
    attributes = params.permit(:first_name, :last_name, :email, :phone_number)
    if attributes.key?(:email) && attributes[:email].to_s.strip.downcase != user.email.downcase
      unless user.authenticate(params[:current_password].to_s)
        return render json: { errors: ['Enter your current password to change your email.'] }, status: :unprocessable_entity
      end
    end
    if user.update(attributes)
      render json: profile(user)
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def profile(user)
    user.slice(:id, :first_name, :last_name, :email, :phone_number)
  end
end

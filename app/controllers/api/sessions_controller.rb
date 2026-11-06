class Api::SessionsController < ApplicationController

  def create
    user = User.find_by("LOWER(email) = ?", params[:email].to_s.strip.downcase)
    if user && user.authenticate(params[:password])
      jwt = JWT.encode(
        {
          session_version: user.session_version,
          user_id: user.id,
          exp: 24.hours.from_now.to_i,
        },
        Rails.application.secret_key_base,
        "HS256"
      )

      render json: { jwt: jwt, email: user.email, user_id: user.id }, status: :created
    else
      render json: {}, status: :unauthorized
    end
  end
end

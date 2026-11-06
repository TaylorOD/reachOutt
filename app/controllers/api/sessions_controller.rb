class Api::SessionsController < ApplicationController
  # Creates a new session by authenticating the user's credentials.
  #
  # Params:
  # - email: The email address of the user.
  # - password: The password of the user.
  #
  # Returns:
  # - If the user is authenticated successfully, it returns a JSON object containing a JWT token, email, and user ID.
  # - If the user is not authenticated, it returns an empty JSON object with an unauthorized status.
  def create
    user = User.find_by("LOWER(email) = ?", params[:email].to_s.strip.downcase)
    if user && user.authenticate(params[:password])
      jwt = JWT.encode(
        {
          session_version: user.session_version,
          user_id: user.id, # the data to encode
          exp: 24.hours.from_now.to_i, # the expiration time
        },
        Rails.application.secret_key_base, # the secret key
        "HS256" # the encryption algorithm
      )
      
      render json: { jwt: jwt, email: user.email, user_id: user.id }, status: :created
    else
      render json: {}, status: :unauthorized
    end
  end
end

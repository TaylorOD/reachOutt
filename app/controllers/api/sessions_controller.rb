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
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
          exp: 24.hours.from_now.to_i, # the expiration time
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
      
      render json: { jwt: jwt, email: user.email, user_id: user.id }, status: :created
    else
      render json: {}, status: :unauthorized
    end
  end

  def show
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      decoded = JWT.decode(header, Rails.application.credentials.fetch(:secret_key_base))[0]
      @user = User.find(decoded["user_id"])
      render json: @user
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { error: e.message }, status: :unauthorized
  end
  end
end

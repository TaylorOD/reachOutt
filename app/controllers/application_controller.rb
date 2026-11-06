class ApplicationController < ActionController::API
  before_action :set_default_response_format

  def current_user
    auth_headers = request.headers["Authorization"]
    if auth_headers.present? && (match = /\ABearer (\S+)\z/.match(auth_headers))
      token = match[1]
      begin
        decoded_token = JWT.decode(
          token,
          Rails.application.secret_key_base,
          true,
          { algorithm: "HS256" }
        )
        User.find_by(id: decoded_token[0]["user_id"])
      rescue JWT::DecodeError
        nil
      end
    end
  end


  def authenticate_user
    unless current_user
      render json: { error: 'Not Authorized' }, status: 401
    end
  end

  private

  def set_default_response_format
    request.format = :json
  end
end

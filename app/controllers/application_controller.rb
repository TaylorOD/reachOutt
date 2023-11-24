class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def current_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @user ||= User.find_by(id: user_id)
    else 
      nil
    end
  end

  def decoded_token
    header = request.headers['Authorization']
    if header
      token = header.split(' ')[1]
      begin
        JWT.decode(token, 'your_secret_key', true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  helper_method :current_user

  def authenticate_user
    unless current_user
      render json: { error: 'Not Authorized' }, status: 401
    end
  end
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  private
  def require_authenticated
    unless auth_user
      self.headers['WWW-Authenticate'] = 'Token realm="Application"'
      render json: {danger: "Must be logged in to access that page."}, status: :unauthorized
    end
  end

  def require_current
    user = auth_user
    unless user and (user == @user or user.admin)
      render json: {danger: "Cannot access other users' information."}, status: :forbidden
    end
  end

  def require_admin
    user = auth_user
    unless user and user.admin
      render json: {danger: "Must be an admin to access that page."}, status: :forbidden
    end
  end

  def auth_user
    authenticate_with_http_token do |token, options|
      User.find_by(api_key: token)
    end
  end
end

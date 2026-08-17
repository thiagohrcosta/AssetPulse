module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    raise ExceptionHandler::MissingToken, 'Missing token' if token.nil?

    @decoded = JsonWebToken.decode(token)
    @current_user = User.find(@decoded[:user_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :unauthorized
  end

  def current_user
    @current_user
  end
end
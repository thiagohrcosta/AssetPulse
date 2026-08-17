module ExceptionHandler
  extend ActiveSupport::Concern

  class MissingToken < StandardError; end
  class InvalidToken < StandardError; end

  included do
    rescue_from ExceptionHandler::MissingToken do |e|
      render json: { error: e.message }, status: :unauthorized
    end

    rescue_from ExceptionHandler::InvalidToken do |e|
      render json: { error: e.message }, status: :unauthorized
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { error: e.message }, status: :not_found
    end
  end
end

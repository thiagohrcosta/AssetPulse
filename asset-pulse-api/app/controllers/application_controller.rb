class ApplicationController < ActionController::Base
  include ExceptionHandler

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # This app is a stateless JSON API authenticated via JWT bearer tokens
  # (see Authenticatable), not cookies/sessions, so CSRF protection does
  # not apply and only blocks legitimate API requests.
  skip_before_action :verify_authenticity_token
end

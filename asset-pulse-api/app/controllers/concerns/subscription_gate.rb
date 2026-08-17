# Blocks access once a company's trial has expired and it has no valid
# paid subscription (Subscription#access_granted?). Include this — after
# Authenticatable — in any controller for a resource that should be
# unavailable until the company is on a trial or a paid plan, e.g.:
#
#   class Api::V1::AssetsController < ApplicationController
#     include Authenticatable
#     include SubscriptionGate
#   end
#
# Not applied to CompaniesController: a company must be creatable (and
# readable, to drive the plan-selection screen) before it has any
# subscription at all.
#
# Expects a `params[:company_id]` (nested company resources) or a
# `#current_company` override in the including controller.
module SubscriptionGate
  extend ActiveSupport::Concern

  included do
    before_action :require_active_subscription!
  end

  private

  def require_active_subscription!
    subscription = current_company&.subscription

    return if subscription&.access_granted?

    render json: {
      error: "Trial expired or no active subscription. Please subscribe to continue.",
      subscription_status: subscription&.status || "none"
    }, status: :payment_required
  end

  def current_company
    return @current_company if defined?(@current_company)

    @current_company = current_user.companies.find_by(id: params[:company_id])
  end
end

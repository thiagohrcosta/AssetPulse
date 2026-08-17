class Api::V1::PlansController < ApplicationController
  include Authenticatable

  # GET /api/v1/plans
  #
  # Feeds the plan-selection screen shown right after a company is created.
  def index
    plans = Plan.active.order(:amount_cents).map do |plan|
      plan.as_json(only: %i[id slug name amount_cents currency interval ai_enabled]).merge(amount: plan.amount)
    end

    render json: plans, status: :ok
  end
end

class Api::V1::SubscriptionsController < ApplicationController
  include Authenticatable

  before_action :set_company

  # GET /api/v1/companies/:company_id/subscription
  def show
    render json: subscription_json(@company.subscription), status: :ok
  end

  # POST /api/v1/companies/:company_id/subscription/trial
  def trial
    if @company.subscription.present?
      return render json: { error: "This company already has a subscription." }, status: :unprocessable_entity
    end

    subscription = @company.build_subscription(status: "trialing", trial_ends_at: Subscription::TRIAL_PERIOD.from_now)
    subscription.save!

    render json: subscription_json(subscription), status: :created
  end

  # POST /api/v1/companies/:company_id/subscription/checkout_session
  def checkout_session
    plan = Plan.active.find_by(slug: params[:plan_slug])
    return render json: { error: "Unknown plan." }, status: :unprocessable_entity unless plan

    ensure_stripe_customer!

    session = Stripe::Checkout::Session.create(
      customer: @company.subscription.stripe_customer_id,
      mode: "subscription",
      line_items: [{ price: plan.stripe_price_id, quantity: 1 }],
      client_reference_id: @company.id,
      subscription_data: { metadata: { company_id: @company.id, plan_slug: plan.slug } },
      metadata: { company_id: @company.id, plan_slug: plan.slug },
      success_url: params[:success_url].presence || "#{ENV.fetch('STRIPE_CHECKOUT_SUCCESS_URL')}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: params[:cancel_url].presence || ENV.fetch("STRIPE_CHECKOUT_CANCEL_URL")
    )

    render json: { checkout_url: session.url }, status: :ok
  end

  # POST /api/v1/companies/:company_id/subscription/billing_portal
  #
  # Lets an already-paying company manage/cancel their subscription or
  # update their card via Stripe's hosted billing portal.
  def billing_portal
    unless @company.subscription&.stripe_customer_id.present?
      return render json: { error: "This company has no billing account yet." }, status: :unprocessable_entity
    end

    session = Stripe::BillingPortal::Session.create(
      customer: @company.subscription.stripe_customer_id,
      return_url: params[:return_url].presence || ENV.fetch("STRIPE_CHECKOUT_CANCEL_URL")
    )

    render json: { portal_url: session.url }, status: :ok
  end

  private

  def set_company
    @company = current_user.companies.find(params[:company_id])
  end

  def ensure_stripe_customer!
    subscription = @company.subscription || @company.build_subscription(status: "trialing")

    if subscription.stripe_customer_id.blank?
      customer = Stripe::Customer.create(
        email: current_user.email,
        name: @company.name,
        metadata: { company_id: @company.id }
      )
      subscription.stripe_customer_id = customer.id
    end

    subscription.save!
  end

  def subscription_json(subscription)
    if subscription.nil?
      return {
        id: nil,
        status: "none",
        plan: nil,
        trial_ends_at: nil,
        current_period_end: nil,
        cancel_at_period_end: nil,
        access_granted: false
      }
    end

    subscription.as_json(
      only: %i[id status trial_ends_at current_period_end cancel_at_period_end],
      methods: []
    ).merge(
      plan: subscription.plan&.slug,
      access_granted: subscription.access_granted?
    )
  end
end

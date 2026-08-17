# Note the `::Stripe` (leading `::`) below: inside Api::V1::Stripe, a bare
# `Stripe` constant would resolve to this namespace, not the stripe gem.
class Api::V1::Stripe::WebhooksController < ApplicationController
  # POST /api/v1/stripe/webhooks
  def create
    event = verify_event!
    return unless event

    Subscriptions::WebhookHandler.call(event)
    head :ok
  rescue StandardError => e
    Rails.logger.error("[stripe_webhook] failed to process #{event&.type}: #{e.class} #{e.message}")
    head :unprocessable_entity
  end

  private

  def verify_event!
    payload = request.body.read
    signature = request.headers["Stripe-Signature"]
    endpoint_secret = ENV.fetch("STRIPE_WEBHOOK_SECRET")

    ::Stripe::Webhook.construct_event(payload, signature, endpoint_secret)
  rescue JSON::ParserError
    render json: { error: "Invalid payload." }, status: :bad_request
    nil
  rescue ::Stripe::SignatureVerificationError
    render json: { error: "Invalid signature." }, status: :bad_request
    nil
  end
end

module Subscriptions
  class WebhookHandler
    def self.call(event)
      new(event).call
    end

    def initialize(event)
      @event = event
    end

    def call
      case event.type
      when "checkout.session.completed"
        handle_checkout_session_completed(event.data.object)
      when "customer.subscription.created", "customer.subscription.updated"
        handle_subscription_change(event.data.object)
      when "customer.subscription.deleted"
        handle_subscription_deleted(event.data.object)
      else
        Rails.logger.info("[stripe_webhook] ignoring unhandled event #{event.type}")
      end
    end

    private

    attr_reader :event

    def handle_checkout_session_completed(session)
      return unless session.mode == "subscription"

      company = Company.find_by(id: session.client_reference_id || session.metadata["company_id"])
      return Rails.logger.warn("[stripe_webhook] checkout.session.completed: no company for session #{session.id}") unless company

      stripe_subscription = Stripe::Subscription.retrieve(session.subscription)
      upsert_subscription(company: company, stripe_subscription: stripe_subscription, stripe_customer_id: session.customer)
    end

    def handle_subscription_change(stripe_subscription)
      subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
      company = subscription&.company || Company.find_by(id: stripe_subscription.metadata["company_id"])
      return Rails.logger.warn("[stripe_webhook] #{event.type}: no company for subscription #{stripe_subscription.id}") unless company

      upsert_subscription(company: company, stripe_subscription: stripe_subscription, stripe_customer_id: stripe_subscription.customer)
    end

    def handle_subscription_deleted(stripe_subscription)
      subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
      return unless subscription

      subscription.update!(status: "canceled")
    end

    def upsert_subscription(company:, stripe_subscription:, stripe_customer_id:)
      subscription = company.subscription || company.build_subscription

      plan = Plan.find_by(stripe_price_id: stripe_subscription.items.data.first&.price&.id)
      period_end = stripe_subscription.respond_to?(:current_period_end) ? stripe_subscription.current_period_end : nil

      subscription.update!(
        plan: plan || subscription.plan,
        status: stripe_subscription.status,
        stripe_customer_id: stripe_customer_id,
        stripe_subscription_id: stripe_subscription.id,
        current_period_end: period_end ? Time.zone.at(period_end) : subscription.current_period_end,
        cancel_at_period_end: stripe_subscription.cancel_at_period_end
      )
    end
  end
end

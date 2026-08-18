require "rails_helper"

RSpec.describe Subscriptions::WebhookHandler do
  def stripe_subscription_double(id:, status: "active", customer: "cus_1", price_id: nil, current_period_end: nil, cancel_at_period_end: false, metadata: {})
    price_item = price_id ? double(price: double(id: price_id)) : nil
    items = double(data: [ price_item ].compact)

    attrs = {
      id: id,
      status: status,
      customer: customer,
      items: items,
      cancel_at_period_end: cancel_at_period_end,
      metadata: metadata
    }
    attrs[:current_period_end] = current_period_end if current_period_end

    double("Stripe::Subscription", **attrs)
  end

  describe ".call" do
    it "dispatches checkout.session.completed" do
      event = double(type: "checkout.session.completed", data: double(object: double(mode: "payment")))

      # mode != "subscription" short-circuits, so nothing else is touched.
      expect { described_class.call(event) }.not_to raise_error
    end

    it "dispatches customer.subscription.created/updated" do
      company = create(:company)
      stripe_subscription = stripe_subscription_double(id: "sub_1", price_id: nil, metadata: { "company_id" => company.id.to_s })
      event = double(type: "customer.subscription.created", data: double(object: stripe_subscription))

      described_class.call(event)

      expect(company.reload.subscription.stripe_subscription_id).to eq("sub_1")
    end

    it "dispatches customer.subscription.deleted" do
      company = create(:company)
      subscription = create(:subscription, :active, company: company, stripe_subscription_id: "sub_del")
      stripe_subscription = stripe_subscription_double(id: "sub_del")
      event = double(type: "customer.subscription.deleted", data: double(object: stripe_subscription))

      described_class.call(event)

      expect(subscription.reload.status).to eq("canceled")
    end

    it "logs and ignores unhandled event types" do
      event = double(type: "invoice.paid", data: double(object: double))

      expect(Rails.logger).to receive(:info).with(/ignoring unhandled event/)
      described_class.call(event)
    end
  end

  describe "#handle_checkout_session_completed" do
    it "does nothing when the session is not a subscription" do
      session = double(mode: "payment")
      event = double(type: "checkout.session.completed", data: double(object: session))

      expect(Company).not_to receive(:find_by)
      described_class.call(event)
    end

    it "warns and returns when no company matches" do
      session = double(mode: "subscription", client_reference_id: nil, metadata: { "company_id" => "999999" }, id: "cs_1")
      event = double(type: "checkout.session.completed", data: double(object: session))

      expect(Rails.logger).to receive(:warn).with(/no company for session/)
      described_class.call(event)
    end

    it "retrieves the Stripe subscription and upserts it via client_reference_id" do
      company = create(:company)
      session = double(mode: "subscription", client_reference_id: company.id.to_s, customer: "cus_new", subscription: "sub_new")
      stripe_subscription = stripe_subscription_double(id: "sub_new", price_id: "price_x")
      allow(Stripe::Subscription).to receive(:retrieve).with("sub_new").and_return(stripe_subscription)
      event = double(type: "checkout.session.completed", data: double(object: session))

      described_class.call(event)

      subscription = company.reload.subscription
      expect(subscription.stripe_customer_id).to eq("cus_new")
      expect(subscription.stripe_subscription_id).to eq("sub_new")
    end
  end

  describe "#handle_subscription_change" do
    it "finds the company via an existing subscription record" do
      company = create(:company)
      existing = create(:subscription, :active, company: company, stripe_subscription_id: "sub_known")
      stripe_subscription = stripe_subscription_double(id: "sub_known", status: "past_due")
      event = double(type: "customer.subscription.updated", data: double(object: stripe_subscription))

      described_class.call(event)

      expect(existing.reload.status).to eq("past_due")
    end

    it "falls back to metadata company_id and warns when no company is found at all" do
      stripe_subscription = stripe_subscription_double(id: "sub_orphan", metadata: { "company_id" => "999999" })
      event = double(type: "customer.subscription.updated", data: double(object: stripe_subscription))

      expect(Rails.logger).to receive(:warn).with(/no company for subscription/)
      described_class.call(event)
    end

    it "sets the matched plan when a price id matches" do
      company = create(:company)
      plan = create(:plan, stripe_price_id: "price_match")
      stripe_subscription = stripe_subscription_double(id: "sub_plan", price_id: "price_match", metadata: { "company_id" => company.id.to_s })
      event = double(type: "customer.subscription.updated", data: double(object: stripe_subscription))

      described_class.call(event)

      expect(company.reload.subscription.plan).to eq(plan)
    end

    it "sets current_period_end when the Stripe object responds to it" do
      company = create(:company)
      timestamp = 2.days.from_now.to_i
      stripe_subscription = stripe_subscription_double(id: "sub_period", current_period_end: timestamp, metadata: { "company_id" => company.id.to_s })
      event = double(type: "customer.subscription.updated", data: double(object: stripe_subscription))

      described_class.call(event)

      expect(company.reload.subscription.current_period_end.to_i).to eq(timestamp)
    end
  end

  describe "#handle_subscription_deleted" do
    it "does nothing when no matching subscription exists" do
      stripe_subscription = stripe_subscription_double(id: "sub_missing")
      event = double(type: "customer.subscription.deleted", data: double(object: stripe_subscription))

      expect { described_class.call(event) }.not_to raise_error
    end
  end
end

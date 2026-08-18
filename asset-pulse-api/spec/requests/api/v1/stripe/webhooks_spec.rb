require "rails_helper"

RSpec.describe "Api::V1::Stripe::Webhooks", type: :request do
  let(:event) { double("Stripe::Event", type: "customer.subscription.updated") }

  describe "POST /api/v1/stripe/webhooks" do
    it "processes a verified event and returns ok" do
      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)
      allow(Subscriptions::WebhookHandler).to receive(:call).with(event)

      post "/api/v1/stripe/webhooks", params: "{}", headers: { "Stripe-Signature" => "sig" }

      expect(response).to have_http_status(:ok)
      expect(Subscriptions::WebhookHandler).to have_received(:call).with(event)
    end

    it "returns bad_request for an invalid payload" do
      allow(Stripe::Webhook).to receive(:construct_event).and_raise(JSON::ParserError)

      post "/api/v1/stripe/webhooks", params: "not-json", headers: { "Stripe-Signature" => "sig" }

      expect(response).to have_http_status(:bad_request)
      expect(json[:error]).to eq("Invalid payload.")
    end

    it "returns bad_request for an invalid signature" do
      allow(Stripe::Webhook).to receive(:construct_event)
        .and_raise(Stripe::SignatureVerificationError.new("bad sig", "sig_header"))

      post "/api/v1/stripe/webhooks", params: "{}", headers: { "Stripe-Signature" => "bad" }

      expect(response).to have_http_status(:bad_request)
      expect(json[:error]).to eq("Invalid signature.")
    end

    it "returns unprocessable_entity when the handler raises" do
      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)
      allow(Subscriptions::WebhookHandler).to receive(:call).and_raise(StandardError, "boom")

      post "/api/v1/stripe/webhooks", params: "{}", headers: { "Stripe-Signature" => "sig" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

require "rails_helper"

RSpec.describe "Api::V1::Subscriptions", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:company) { create(:company, user: user) }

  describe "GET /api/v1/companies/:company_id/subscription" do
    it "returns a placeholder when there is no subscription" do
      get "/api/v1/companies/#{company.id}/subscription", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json[:status]).to eq("none")
      expect(json[:access_granted]).to be false
    end

    it "returns the subscription when present" do
      plan = create(:plan)
      subscription = create(:subscription, :active, company: company, plan: plan)

      get "/api/v1/companies/#{company.id}/subscription", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json[:id]).to eq(subscription.id)
      expect(json[:plan]).to eq(plan.slug)
      expect(json[:access_granted]).to be true
    end
  end

  describe "POST /api/v1/companies/:company_id/subscription/trial" do
    it "creates a trial subscription" do
      post "/api/v1/companies/#{company.id}/subscription/trial", headers: headers

      expect(response).to have_http_status(:created)
      expect(json[:status]).to eq("trialing")
    end

    it "refuses a second subscription" do
      create(:subscription, company: company)

      post "/api/v1/companies/#{company.id}/subscription/trial", headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:error]).to eq("This company already has a subscription.")
    end
  end

  describe "POST /api/v1/companies/:company_id/subscription/checkout_session" do
    let(:plan) { create(:plan, slug: "basic", stripe_price_id: "price_123") }

    it "returns unprocessable_entity for an unknown plan" do
      post "/api/v1/companies/#{company.id}/subscription/checkout_session",
           params: { plan_slug: "does-not-exist" }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "creates a Stripe customer and checkout session" do
      plan
      customer = double("Stripe::Customer", id: "cus_new123")
      session = double("Stripe::Checkout::Session", url: "https://stripe.example/checkout")

      allow(Stripe::Customer).to receive(:create).and_return(customer)
      allow(Stripe::Checkout::Session).to receive(:create).and_return(session)

      post "/api/v1/companies/#{company.id}/subscription/checkout_session",
           params: { plan_slug: "basic" }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json[:checkout_url]).to eq("https://stripe.example/checkout")
      expect(company.reload.subscription.stripe_customer_id).to eq("cus_new123")
    end

    it "reuses an existing stripe_customer_id" do
      plan
      create(:subscription, company: company, stripe_customer_id: "cus_existing")
      session = double("Stripe::Checkout::Session", url: "https://stripe.example/checkout")

      expect(Stripe::Customer).not_to receive(:create)
      allow(Stripe::Checkout::Session).to receive(:create).and_return(session)

      post "/api/v1/companies/#{company.id}/subscription/checkout_session",
           params: { plan_slug: "basic" }, headers: headers

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/v1/companies/:company_id/subscription/billing_portal" do
    it "returns unprocessable_entity without a billing account" do
      post "/api/v1/companies/#{company.id}/subscription/billing_portal", headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns a billing portal url" do
      create(:subscription, company: company, stripe_customer_id: "cus_existing")
      portal_session = double("Stripe::BillingPortal::Session", url: "https://stripe.example/portal")
      allow(Stripe::BillingPortal::Session).to receive(:create).and_return(portal_session)

      post "/api/v1/companies/#{company.id}/subscription/billing_portal", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json[:portal_url]).to eq("https://stripe.example/portal")
    end
  end
end

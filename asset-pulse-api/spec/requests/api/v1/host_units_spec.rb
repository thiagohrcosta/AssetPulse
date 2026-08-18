require "rails_helper"

RSpec.describe "Api::V1::HostUnits", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:company) { create(:company, user: user) }

  before { create(:subscription, company: company) }

  describe "GET /api/v1/companies/:company_id/host_units" do
    it "lists host units for the company" do
      host_unit = create(:host_unit, company: company)

      get "/api/v1/companies/#{company.id}/host_units", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json.map { |h| h[:id] }).to eq([ host_unit.id ])
    end

    it "returns payment_required for a company the user does not own" do
      # SubscriptionGate resolves #current_company (scoped to current_user's
      # own companies) before #set_company runs, so an unowned company_id
      # looks like "no company/subscription" rather than a 404.
      other_company = create(:company)

      get "/api/v1/companies/#{other_company.id}/host_units", headers: headers

      expect(response).to have_http_status(:payment_required)
    end

    it "returns payment_required when the trial has expired" do
      company.subscription.update!(trial_ends_at: 1.day.ago)

      get "/api/v1/companies/#{company.id}/host_units", headers: headers

      expect(response).to have_http_status(:payment_required)
      expect(json[:subscription_status]).to eq("trialing")
    end
  end

  describe "GET /api/v1/companies/:company_id/host_units/:id" do
    it "returns the host unit" do
      host_unit = create(:host_unit, company: company)

      get "/api/v1/companies/#{company.id}/host_units/#{host_unit.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json[:vin]).to eq(host_unit.vin)
    end
  end

  describe "POST /api/v1/companies/:company_id/host_units" do
    it "creates a host unit" do
      params = { host_unit: { vin: "1HGCM82633A123456", description: "Truck" } }

      post "/api/v1/companies/#{company.id}/host_units", params: params, headers: headers

      expect(response).to have_http_status(:created)
      expect(json[:vin]).to eq("1HGCM82633A123456")
    end

    it "returns errors when invalid" do
      post "/api/v1/companies/#{company.id}/host_units", params: { host_unit: { vin: "" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/companies/:company_id/host_units/:id" do
    it "updates the host unit" do
      host_unit = create(:host_unit, company: company)

      patch "/api/v1/companies/#{company.id}/host_units/#{host_unit.id}",
            params: { host_unit: { description: "Updated" } }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json[:description]).to eq("Updated")
    end

    it "returns errors when invalid" do
      host_unit = create(:host_unit, company: company)

      patch "/api/v1/companies/#{company.id}/host_units/#{host_unit.id}",
            params: { host_unit: { description: "" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to be_present
    end
  end

  describe "DELETE /api/v1/companies/:company_id/host_units/:id" do
    it "destroys the host unit" do
      host_unit = create(:host_unit, company: company)

      delete "/api/v1/companies/#{company.id}/host_units/#{host_unit.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(HostUnit.exists?(host_unit.id)).to be false
    end
  end
end

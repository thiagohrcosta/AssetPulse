require "rails_helper"

RSpec.describe "Api::V1::Companies", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe "GET /api/v1/companies" do
    it "requires authentication" do
      get "/api/v1/companies"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns only the current user's companies" do
      mine = create(:company, user: user)
      create(:company)

      get "/api/v1/companies", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json.map { |c| c[:id] }).to eq([ mine.id ])
      expect(json.first).to have_key(:logo_url)
      expect(json.first).not_to have_key(:user_id)
    end
  end

  describe "GET /api/v1/companies/:id" do
    it "returns the company when owned by the current user" do
      company = create(:company, user: user)

      get "/api/v1/companies/#{company.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json[:id]).to eq(company.id)
    end

    it "returns not_found for another user's company" do
      other_company = create(:company)

      get "/api/v1/companies/#{other_company.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/companies" do
    let(:valid_params) do
      {
        company: {
          name: "Acme Fleet",
          registration_number: "REG-001",
          address_zip_code: "12345678",
          address_street: "Main St",
          address_number: "10",
          address_city: "Springfield",
          address_complement: "Suite 1",
          address_state: "SP"
        }
      }
    end

    it "creates a company for the current user" do
      expect {
        post "/api/v1/companies", params: valid_params, headers: headers
      }.to change { user.companies.count }.by(1)

      expect(response).to have_http_status(:created)
      expect(json[:name]).to eq("Acme Fleet")
    end

    it "returns errors when invalid" do
      post "/api/v1/companies", params: { company: { name: "" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to be_present
    end
  end

  describe "PATCH /api/v1/companies/:id" do
    it "updates the company" do
      company = create(:company, user: user)

      patch "/api/v1/companies/#{company.id}", params: { company: { name: "Renamed" } }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json[:name]).to eq("Renamed")
    end

    it "returns errors when invalid" do
      company = create(:company, user: user)

      patch "/api/v1/companies/#{company.id}", params: { company: { name: "" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/companies/:id" do
    it "destroys the company" do
      company = create(:company, user: user)

      delete "/api/v1/companies/#{company.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(Company.exists?(company.id)).to be false
    end
  end
end

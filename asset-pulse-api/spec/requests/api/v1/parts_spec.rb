require "rails_helper"

RSpec.describe "Api::V1::Parts", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:company) { create(:company, user: user) }
  let(:part_type_reference) { create(:part_type_reference) }

  before { create(:subscription, company: company) }

  describe "GET /api/v1/companies/:company_id/parts" do
    it "lists parts for the company" do
      part = create(:part, company: company, part_type_reference: part_type_reference)

      get "/api/v1/companies/#{company.id}/parts", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json.map { |p| p[:id] }).to eq([ part.id ])
      expect(json.first[:part_type]).to eq(part_type_reference.part_type)
    end

    it "filters by status, host_unit_id and part_type_reference_id" do
      host_unit = create(:host_unit, company: company)
      matching = create(:part, company: company, part_type_reference: part_type_reference, host_unit: host_unit, status: "installed")
      create(:part, company: company, part_type_reference: part_type_reference, status: "removed")

      get "/api/v1/companies/#{company.id}/parts",
          params: { status: "installed", host_unit_id: host_unit.id, part_type_reference_id: part_type_reference.id },
          headers: headers

      expect(json.map { |p| p[:id] }).to eq([ matching.id ])
    end
  end

  describe "GET /api/v1/companies/:company_id/parts/:id" do
    it "returns the part" do
      part = create(:part, company: company, part_type_reference: part_type_reference)

      get "/api/v1/companies/#{company.id}/parts/#{part.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json[:id]).to eq(part.id)
    end
  end

  describe "POST /api/v1/companies/:company_id/parts" do
    let(:valid_params) do
      {
        part: {
          part_type_reference_id: part_type_reference.id,
          serial_number: "SN-12345",
          manufacturer: "Bosch",
          model: "X1"
        }
      }
    end

    it "creates a part" do
      post "/api/v1/companies/#{company.id}/parts", params: valid_params, headers: headers

      expect(response).to have_http_status(:created)
      expect(json[:serial_number]).to eq("SN-12345")
    end

    it "rejects a host_unit belonging to another company" do
      other_host_unit = create(:host_unit)
      params = valid_params.deep_merge(part: { host_unit_id: other_host_unit.id })

      post "/api/v1/companies/#{company.id}/parts", params: params, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to include("host_unit_id must belong to this company")
    end

    it "accepts a host_unit belonging to the same company" do
      host_unit = create(:host_unit, company: company)
      params = valid_params.deep_merge(part: { host_unit_id: host_unit.id })

      post "/api/v1/companies/#{company.id}/parts", params: params, headers: headers

      expect(response).to have_http_status(:created)
      expect(json[:host_unit_id]).to eq(host_unit.id)
    end

    it "returns errors when invalid" do
      post "/api/v1/companies/#{company.id}/parts", params: { part: { manufacturer: "" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/companies/:company_id/parts/:id" do
    it "updates the part" do
      part = create(:part, company: company, part_type_reference: part_type_reference)

      patch "/api/v1/companies/#{company.id}/parts/#{part.id}",
            params: { part: { model: "Updated" } }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json[:model]).to eq("Updated")
    end

    it "rejects a host_unit belonging to another company" do
      part = create(:part, company: company, part_type_reference: part_type_reference)
      other_host_unit = create(:host_unit)

      patch "/api/v1/companies/#{company.id}/parts/#{part.id}",
            params: { part: { host_unit_id: other_host_unit.id } }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns errors when invalid" do
      part = create(:part, company: company, part_type_reference: part_type_reference)

      patch "/api/v1/companies/#{company.id}/parts/#{part.id}",
            params: { part: { manufacturer: "" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to be_present
    end
  end

  describe "DELETE /api/v1/companies/:company_id/parts/:id" do
    it "destroys the part" do
      part = create(:part, company: company, part_type_reference: part_type_reference)

      delete "/api/v1/companies/#{company.id}/parts/#{part.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(Part.exists?(part.id)).to be false
    end
  end
end

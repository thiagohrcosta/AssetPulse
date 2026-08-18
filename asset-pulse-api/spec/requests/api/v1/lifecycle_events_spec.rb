require "rails_helper"

RSpec.describe "Api::V1::LifecycleEvents", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:company) { create(:company, user: user) }
  let(:part) { create(:part, company: company) }

  before { create(:subscription, company: company) }

  describe "GET .../lifecycle_events" do
    it "lists events chronologically" do
      later = create(:lifecycle_event, part: part, company: company, occurred_at: 1.day.ago)
      earlier = create(:lifecycle_event, part: part, company: company, occurred_at: 10.days.ago)

      get "/api/v1/companies/#{company.id}/parts/#{part.id}/lifecycle_events", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json.map { |e| e[:id] }).to eq([ earlier.id, later.id ])
    end
  end

  describe "GET .../lifecycle_events/:id" do
    it "returns the event" do
      event = create(:lifecycle_event, part: part, company: company)

      get "/api/v1/companies/#{company.id}/parts/#{part.id}/lifecycle_events/#{event.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json[:id]).to eq(event.id)
    end
  end

  describe "POST .../lifecycle_events" do
    let(:valid_params) do
      { lifecycle_event: { event_type: "installed", occurred_at: Time.current, age_at_event_days: 0 } }
    end

    it "creates an event scoped to the part's company" do
      post "/api/v1/companies/#{company.id}/parts/#{part.id}/lifecycle_events", params: valid_params, headers: headers

      expect(response).to have_http_status(:created)
      expect(json[:company_id]).to eq(company.id)
    end

    it "rejects a host_unit belonging to another company" do
      other_host_unit = create(:host_unit)
      params = valid_params.deep_merge(lifecycle_event: { host_unit_id: other_host_unit.id })

      post "/api/v1/companies/#{company.id}/parts/#{part.id}/lifecycle_events", params: params, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to include("host_unit_id must belong to this company")
    end

    it "accepts a host_unit belonging to the same company" do
      host_unit = create(:host_unit, company: company)
      params = valid_params.deep_merge(lifecycle_event: { host_unit_id: host_unit.id })

      post "/api/v1/companies/#{company.id}/parts/#{part.id}/lifecycle_events", params: params, headers: headers

      expect(response).to have_http_status(:created)
    end

    it "returns errors when invalid" do
      post "/api/v1/companies/#{company.id}/parts/#{part.id}/lifecycle_events",
           params: { lifecycle_event: { event_type: "" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH .../lifecycle_events/:id" do
    it "updates the event" do
      event = create(:lifecycle_event, part: part, company: company)

      patch "/api/v1/companies/#{company.id}/parts/#{part.id}/lifecycle_events/#{event.id}",
            params: { lifecycle_event: { notes: "Updated note" } }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json[:notes]).to eq("Updated note")
    end

    it "rejects a host_unit belonging to another company" do
      event = create(:lifecycle_event, part: part, company: company)
      other_host_unit = create(:host_unit)

      patch "/api/v1/companies/#{company.id}/parts/#{part.id}/lifecycle_events/#{event.id}",
            params: { lifecycle_event: { host_unit_id: other_host_unit.id } }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns errors when invalid" do
      event = create(:lifecycle_event, part: part, company: company)

      patch "/api/v1/companies/#{company.id}/parts/#{part.id}/lifecycle_events/#{event.id}",
            params: { lifecycle_event: { age_at_event_days: -1 } }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to be_present
    end
  end

  describe "DELETE .../lifecycle_events/:id" do
    it "destroys the event" do
      event = create(:lifecycle_event, part: part, company: company)

      delete "/api/v1/companies/#{company.id}/parts/#{part.id}/lifecycle_events/#{event.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(LifecycleEvent.exists?(event.id)).to be false
    end
  end
end

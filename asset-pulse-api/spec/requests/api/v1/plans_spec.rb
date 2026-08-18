require "rails_helper"

RSpec.describe "Api::V1::Plans", type: :request do
  let(:user) { create(:user) }

  describe "GET /api/v1/plans" do
    it "lists only active plans ordered by amount_cents, with amount included" do
      cheap = create(:plan, amount_cents: 999, active: true)
      create(:plan, amount_cents: 500, active: false)
      pricey = create(:plan, amount_cents: 4999, active: true)

      get "/api/v1/plans", headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(json.map { |p| p[:id] }).to eq([ cheap.id, pricey.id ])
      expect(json.first[:amount]).to eq(9.99)
    end

    it "requires authentication" do
      get "/api/v1/plans"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

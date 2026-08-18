require "rails_helper"

RSpec.describe "Api::V1::PartTypeReferences", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  describe "GET /api/v1/part_type_references" do
    it "lists references ordered by part_type for any authenticated user" do
      create(:part_type_reference, part_type: "tire")
      create(:part_type_reference, part_type: "battery")

      get "/api/v1/part_type_references", headers: auth_headers(regular_user)

      expect(response).to have_http_status(:ok)
      expect(json.map { |r| r[:part_type] }).to eq(%w[battery tire])
    end
  end

  describe "GET /api/v1/part_type_references/:id" do
    it "returns the reference" do
      reference = create(:part_type_reference)

      get "/api/v1/part_type_references/#{reference.id}", headers: auth_headers(regular_user)

      expect(response).to have_http_status(:ok)
      expect(json[:id]).to eq(reference.id)
    end
  end

  describe "POST /api/v1/part_type_references" do
    let(:valid_params) { { part_type_reference: { part_type: "tire", typical_lifespan_days: 730 } } }

    it "forbids non-admin users" do
      post "/api/v1/part_type_references", params: valid_params, headers: auth_headers(regular_user)

      expect(response).to have_http_status(:forbidden)
    end

    it "allows admins to create a reference" do
      post "/api/v1/part_type_references", params: valid_params, headers: auth_headers(admin)

      expect(response).to have_http_status(:created)
      expect(json[:part_type]).to eq("tire")
    end

    it "returns errors when invalid" do
      post "/api/v1/part_type_references",
           params: { part_type_reference: { part_type: "not_a_real_type", typical_lifespan_days: 1 } },
           headers: auth_headers(admin)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/part_type_references/:id" do
    it "allows admins to update a reference" do
      reference = create(:part_type_reference)

      patch "/api/v1/part_type_references/#{reference.id}",
            params: { part_type_reference: { typical_lifespan_days: 999 } }, headers: auth_headers(admin)

      expect(response).to have_http_status(:ok)
      expect(json[:typical_lifespan_days]).to eq(999)
    end

    it "forbids non-admin users" do
      reference = create(:part_type_reference)

      patch "/api/v1/part_type_references/#{reference.id}",
            params: { part_type_reference: { typical_lifespan_days: 999 } }, headers: auth_headers(regular_user)

      expect(response).to have_http_status(:forbidden)
    end

    it "returns errors when invalid" do
      reference = create(:part_type_reference)

      patch "/api/v1/part_type_references/#{reference.id}",
            params: { part_type_reference: { typical_lifespan_days: -1 } }, headers: auth_headers(admin)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to be_present
    end
  end

  describe "DELETE /api/v1/part_type_references/:id" do
    it "allows admins to destroy an unreferenced reference" do
      reference = create(:part_type_reference)

      delete "/api/v1/part_type_references/#{reference.id}", headers: auth_headers(admin)

      expect(response).to have_http_status(:no_content)
    end

    it "forbids non-admin users" do
      reference = create(:part_type_reference)

      delete "/api/v1/part_type_references/#{reference.id}", headers: auth_headers(regular_user)

      expect(response).to have_http_status(:forbidden)
    end

    it "leaves the reference in place when parts still reference it" do
      # PartTypeReference has_many :parts, dependent: :restrict_with_error,
      # which blocks the destroy by adding a base error rather than raising
      # ActiveRecord::DeleteRestrictionError (that's :restrict_with_exception).
      # The controller's rescue for that error never fires here, so the
      # response is still no_content even though nothing was deleted.
      reference = create(:part_type_reference)
      create(:part, part_type_reference: reference)

      delete "/api/v1/part_type_references/#{reference.id}", headers: auth_headers(admin)

      expect(response).to have_http_status(:no_content)
      expect(PartTypeReference.exists?(reference.id)).to be true
    end
  end
end

require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth/register" do
    let(:valid_params) do
      {
        email: "new_user@example.com",
        full_name: "Jane Doe",
        document_number: "123456789",
        address_street: "Main St",
        address_number: "10",
        address_city: "Springfield",
        address_complement: "Apt 1",
        address_state: "SP",
        address_zip_code: "12345678",
        password: "P@ssw0rd123",
        password_confirmation: "P@ssw0rd123"
      }
    end

    it "creates a user and returns a token" do
      post "/api/v1/auth/register", params: valid_params

      expect(response).to have_http_status(:created)
      expect(json[:token]).to be_present
      expect(json[:user][:email]).to eq("new_user@example.com")
    end

    it "returns errors when invalid" do
      post "/api/v1/auth/register", params: valid_params.merge(email: "")

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to be_present
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, email: "login@example.com", password: "P@ssw0rd123") }

    it "returns a token for valid credentials" do
      post "/api/v1/auth/login", params: { email: "login@example.com", password: "P@ssw0rd123" }

      expect(response).to have_http_status(:ok)
      expect(json[:token]).to be_present
    end

    it "returns unauthorized for an invalid password" do
      post "/api/v1/auth/login", params: { email: "login@example.com", password: "wrong" }

      expect(response).to have_http_status(:unauthorized)
      expect(json[:error]).to eq("Email ou senha inválidos")
    end

    it "returns unauthorized for an unknown email" do
      post "/api/v1/auth/login", params: { email: "nobody@example.com", password: "whatever" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end

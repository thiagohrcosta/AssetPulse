require "rails_helper"

# Exercises Authenticatable + ExceptionHandler's failure branches — covered
# indirectly by every other authenticated request spec, but tested directly
# here for each distinct failure mode.
RSpec.describe "Authentication", type: :request do
  describe "with no Authorization header" do
    it "returns unauthorized with a missing token message" do
      get "/api/v1/companies"

      expect(response).to have_http_status(:unauthorized)
      expect(json[:error]).to eq("Missing token")
    end
  end

  describe "with a malformed/expired token" do
    it "returns unauthorized with an invalid token message" do
      expired_token = JsonWebToken.encode({ user_id: 1 }, 1.hour.ago)

      get "/api/v1/companies", headers: { "Authorization" => "Bearer #{expired_token}" }

      expect(response).to have_http_status(:unauthorized)
      expect(json[:error]).to be_present
    end
  end

  describe "with a token for a user that no longer exists" do
    it "returns unauthorized with a user not found message" do
      token = JsonWebToken.encode(user_id: 0)

      get "/api/v1/companies", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:unauthorized)
      expect(json[:error]).to eq("User not found")
    end
  end
end

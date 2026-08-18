require "rails_helper"

RSpec.describe JsonWebToken do
  describe ".encode / .decode" do
    it "round-trips a payload" do
      token = described_class.encode(user_id: 42)
      decoded = described_class.decode(token)

      expect(decoded[:user_id]).to eq(42)
    end

    it "embeds an expiration claim" do
      token = described_class.encode({ user_id: 1 }, 1.hour.from_now)
      decoded = described_class.decode(token)

      expect(decoded[:exp]).to be_present
    end

    it "raises InvalidToken for an expired token" do
      token = described_class.encode({ user_id: 1 }, 1.hour.ago)

      expect { described_class.decode(token) }.to raise_error(ExceptionHandler::InvalidToken)
    end

    it "raises InvalidToken for a malformed token" do
      expect { described_class.decode("not-a-real-token") }.to raise_error(ExceptionHandler::InvalidToken)
    end
  end
end

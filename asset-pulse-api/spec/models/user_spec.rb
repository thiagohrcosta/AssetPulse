require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:companies).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:document_number) }
    it { is_expected.to validate_presence_of(:address_zip_code) }
    it { is_expected.to validate_presence_of(:address_street) }
    it { is_expected.to validate_presence_of(:address_number) }
    it { is_expected.to validate_presence_of(:address_city) }
    it { is_expected.to validate_presence_of(:address_state) }
    it "validates uniqueness of document_number" do
      create(:user, document_number: "doc-abc-123")
      is_expected.to validate_uniqueness_of(:document_number)
    end
    it { is_expected.to define_enum_for(:access).with_values(user: 0, admin: 1, company_admin: 2) }
  end

  describe "devise modules" do
    it "authenticates with a valid password" do
      user = create(:user, password: "P@ssw0rd123")
      expect(user.valid_password?("P@ssw0rd123")).to be true
    end

    it "rejects an invalid password" do
      user = create(:user, password: "P@ssw0rd123")
      expect(user.valid_password?("wrong")).to be false
    end
  end

  it "is valid with factory defaults" do
    expect(build(:user)).to be_valid
  end
end

require "rails_helper"

RSpec.describe Company, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_one(:subscription).dependent(:destroy) }
    it { is_expected.to have_many(:host_units).dependent(:destroy) }
    it { is_expected.to have_many(:parts).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:company) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:address_zip_code) }
    it { is_expected.to validate_presence_of(:address_street) }
    it { is_expected.to validate_presence_of(:address_number) }
    it { is_expected.to validate_presence_of(:address_city) }
    it { is_expected.to validate_presence_of(:address_state) }

    it "validates uniqueness of registration_number" do
      create(:company, registration_number: "reg-abc-123")
      is_expected.to validate_uniqueness_of(:registration_number)
    end

    it { is_expected.to define_enum_for(:company_type).with_values(fleet_operator: "fleet_operator", repair_shop: "repair_shop").backed_by_column_of_type(:string) }
  end

  it "is valid with factory defaults" do
    expect(build(:company)).to be_valid
  end

  describe "#logo_must_be_a_valid_image" do
    let(:company) { build(:company) }

    it "is valid when no logo is attached" do
      expect(company).to be_valid
    end

    it "is valid with an accepted content type under the size limit" do
      company.logo.attach(io: StringIO.new("fake-image-bytes"), filename: "logo.png", content_type: "image/png")
      expect(company).to be_valid
    end

    it "is invalid with an unaccepted content type" do
      company.logo.attach(io: StringIO.new("fake-pdf-bytes"), filename: "logo.pdf", content_type: "application/pdf")
      expect(company).not_to be_valid
      expect(company.errors[:logo]).to include("must be a PNG, JPEG or WEBP image")
    end

    it "is invalid when the file exceeds the size limit" do
      company.logo.attach(io: StringIO.new("fake-image-bytes"), filename: "logo.png", content_type: "image/png")
      allow(company.logo).to receive(:byte_size).and_return(6.megabytes)
      expect(company).not_to be_valid
      expect(company.errors[:logo]).to include("must be smaller than 5MB")
    end
  end
end

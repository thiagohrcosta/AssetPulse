require "rails_helper"

RSpec.describe Part, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:part_type_reference) }
    it { is_expected.to belong_to(:host_unit).optional }
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_many(:lifecycle_events).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:part) }

    it { is_expected.to validate_presence_of(:manufacturer) }
    it { is_expected.to validate_presence_of(:model) }

    it "validates uniqueness of serial_number" do
      create(:part, serial_number: "SN-ABC-123")
      is_expected.to validate_uniqueness_of(:serial_number)
    end

    it { is_expected.to define_enum_for(:status).with_values(installed: "installed", in_repair: "in_repair", removed: "removed", scrapped: "scrapped").backed_by_column_of_type(:string) }
  end

  it "is valid with factory defaults" do
    expect(build(:part)).to be_valid
  end

  it "defaults status to installed" do
    expect(Part.new.status).to eq("installed")
  end

  describe "delegation to part_type_reference" do
    let(:reference) { create(:part_type_reference, part_type: "battery", typical_lifespan_days: 365) }
    let(:part) { create(:part, part_type_reference: reference) }

    it "delegates #part_type" do
      expect(part.part_type).to eq("battery")
    end

    it "delegates #typical_lifespan_days" do
      expect(part.typical_lifespan_days).to eq(365)
    end
  end

  describe ".by_manufacturer_model" do
    it "filters parts by manufacturer and model" do
      match = create(:part, manufacturer: "Bosch", model: "X1")
      create(:part, manufacturer: "Bosch", model: "X2")
      create(:part, manufacturer: "Denso", model: "X1")

      expect(Part.by_manufacturer_model("Bosch", "X1")).to contain_exactly(match)
    end
  end
end

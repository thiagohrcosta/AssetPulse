require "rails_helper"

RSpec.describe HostUnit, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_many(:parts).dependent(:nullify) }
  end

  describe "validations" do
    subject { build(:host_unit) }

    it { is_expected.to validate_presence_of(:vin) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_length_of(:vin).is_equal_to(17) }

    it "validates uniqueness of vin" do
      create(:host_unit, vin: "1HGCM82633A123456")
      is_expected.to validate_uniqueness_of(:vin)
    end
  end

  it "is valid with factory defaults" do
    expect(build(:host_unit)).to be_valid
  end
end

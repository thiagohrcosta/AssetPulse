require "rails_helper"

RSpec.describe PartTypeReference, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:parts).dependent(:restrict_with_error) }
  end

  describe "validations" do
    subject { build(:part_type_reference) }

    it { is_expected.to validate_presence_of(:part_type) }
    it { is_expected.to validate_inclusion_of(:part_type).in_array(PartTypeReference::PART_TYPES) }
    it { is_expected.to validate_presence_of(:typical_lifespan_days) }
    it { is_expected.to validate_numericality_of(:typical_lifespan_days).is_greater_than(0).only_integer }

    it "validates uniqueness of part_type" do
      create(:part_type_reference, part_type: "brake_pad")
      is_expected.to validate_uniqueness_of(:part_type)
    end
  end

  it "is valid with factory defaults" do
    expect(build(:part_type_reference)).to be_valid
  end

  it "restricts destruction while parts reference it" do
    reference = create(:part_type_reference)
    create(:part, part_type_reference: reference)

    expect(reference.destroy).to be false
    expect(reference.errors[:base]).to be_present
  end
end

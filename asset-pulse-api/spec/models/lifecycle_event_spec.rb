require "rails_helper"

RSpec.describe LifecycleEvent, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:part) }
    it { is_expected.to belong_to(:host_unit).optional }
    it { is_expected.to belong_to(:company) }
  end

  describe "validations" do
    subject { build(:lifecycle_event) }

    it { is_expected.to validate_presence_of(:event_type) }
    it { is_expected.to validate_presence_of(:occurred_at) }
    it { is_expected.to validate_presence_of(:age_at_event_days) }
    it { is_expected.to validate_numericality_of(:age_at_event_days).is_greater_than_or_equal_to(0).only_integer }

    it {
      is_expected.to define_enum_for(:event_type).with_values(
        installed: "installed",
        maintenance: "maintenance",
        replaced_wear: "replaced_wear",
        replaced_defect: "replaced_defect",
        reassigned: "reassigned",
        scrapped: "scrapped"
      ).backed_by_column_of_type(:string)
    }

    it {
      is_expected.to define_enum_for(:installation_type).with_values(
        factory_original: "factory_original",
        aftermarket_new: "aftermarket_new",
        aftermarket_refurbished: "aftermarket_refurbished"
      ).backed_by_column_of_type(:string)
    }

    it "allows a nil installation_type" do
      expect(build(:lifecycle_event, installation_type: nil)).to be_valid
    end
  end

  it "is valid with factory defaults" do
    expect(build(:lifecycle_event)).to be_valid
  end

  describe ".chronological" do
    it "orders events by occurred_at ascending" do
      part = create(:part)
      later = create(:lifecycle_event, part: part, occurred_at: 1.day.ago)
      earlier = create(:lifecycle_event, part: part, occurred_at: 10.days.ago)

      expect(part.lifecycle_events.chronological).to eq([ earlier, later ])
    end
  end
end

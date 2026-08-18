require "rails_helper"

RSpec.describe Plan, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:subscriptions).dependent(:restrict_with_error) }
  end

  describe "validations" do
    subject { build(:plan) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:amount_cents) }
    it { is_expected.to validate_numericality_of(:amount_cents).is_greater_than(0).only_integer }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_presence_of(:interval) }

    it "validates uniqueness of slug" do
      create(:plan, slug: "unique-slug")
      is_expected.to validate_uniqueness_of(:slug)
    end
  end

  it "is valid with factory defaults" do
    expect(build(:plan)).to be_valid
  end

  describe ".active" do
    it "returns only active plans" do
      active_plan = create(:plan, active: true)
      create(:plan, active: false)

      expect(Plan.active).to contain_exactly(active_plan)
    end
  end

  describe "#amount" do
    it "converts amount_cents to a decimal amount" do
      plan = build(:plan, amount_cents: 4_999)
      expect(plan.amount).to eq(49.99)
    end
  end
end

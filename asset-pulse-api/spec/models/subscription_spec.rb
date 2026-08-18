require "rails_helper"

RSpec.describe Subscription, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:plan).optional }
  end

  describe "validations" do
    subject { build(:subscription) }

    it { is_expected.to validate_presence_of(:status) }

    it "validates uniqueness of company_id" do
      create(:subscription)
      is_expected.to validate_uniqueness_of(:company_id)
    end

    it "validates uniqueness of stripe_customer_id, allowing nil" do
      create(:subscription, :active, stripe_customer_id: "cus_unique_123")
      is_expected.to validate_uniqueness_of(:stripe_customer_id).allow_nil
    end

    it "validates uniqueness of stripe_subscription_id, allowing nil" do
      create(:subscription, :active, stripe_subscription_id: "sub_unique_123")
      is_expected.to validate_uniqueness_of(:stripe_subscription_id).allow_nil
    end

    it {
      is_expected.to define_enum_for(:status).with_values(
        trialing: "trialing",
        active: "active",
        past_due: "past_due",
        unpaid: "unpaid",
        canceled: "canceled",
        incomplete: "incomplete",
        incomplete_expired: "incomplete_expired"
      ).backed_by_column_of_type(:string)
    }
  end

  it "is valid with factory defaults" do
    expect(build(:subscription)).to be_valid
  end

  describe "#access_granted?" do
    it "is true for a trial that hasn't expired" do
      subscription = build(:subscription, status: "trialing", trial_ends_at: 1.day.from_now)
      expect(subscription.access_granted?).to be true
    end

    it "is false for a trial that has expired" do
      subscription = build(:subscription, status: "trialing", trial_ends_at: 1.day.ago)
      expect(subscription.access_granted?).to be false
    end

    it "is false for a trialing subscription with no trial_ends_at" do
      subscription = build(:subscription, status: "trialing", trial_ends_at: nil)
      expect(subscription.access_granted?).to be false
    end

    it "is true when active" do
      subscription = build(:subscription, status: "active")
      expect(subscription.access_granted?).to be true
    end

    it "is true when past_due" do
      subscription = build(:subscription, status: "past_due")
      expect(subscription.access_granted?).to be true
    end

    it "is false when canceled" do
      subscription = build(:subscription, status: "canceled")
      expect(subscription.access_granted?).to be false
    end
  end

  describe "#trial_active?" do
    it "is true when trial_ends_at is in the future" do
      subscription = build(:subscription, trial_ends_at: 1.day.from_now)
      expect(subscription.trial_active?).to be true
    end

    it "is false when trial_ends_at is nil" do
      subscription = build(:subscription, trial_ends_at: nil)
      expect(subscription.trial_active?).to be false
    end

    it "is false when trial_ends_at is in the past" do
      subscription = build(:subscription, trial_ends_at: 1.day.ago)
      expect(subscription.trial_active?).to be false
    end
  end

  describe "#trial_expired?" do
    it "is true when trialing and trial_ends_at has passed" do
      subscription = build(:subscription, status: "trialing", trial_ends_at: 1.day.ago)
      expect(subscription.trial_expired?).to be true
    end

    it "is false when trialing but trial_ends_at is nil" do
      subscription = build(:subscription, status: "trialing", trial_ends_at: nil)
      expect(subscription.trial_expired?).to be false
    end

    it "is false when not trialing" do
      subscription = build(:subscription, status: "active", trial_ends_at: 1.day.ago)
      expect(subscription.trial_expired?).to be false
    end

    it "is false when trial_ends_at is in the future" do
      subscription = build(:subscription, status: "trialing", trial_ends_at: 1.day.from_now)
      expect(subscription.trial_expired?).to be false
    end
  end
end

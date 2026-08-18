FactoryBot.define do
  factory :subscription do
    association :company
    plan { nil }
    status { "trialing" }
    trial_ends_at { 7.days.from_now }

    trait :active do
      status { "active" }
      trial_ends_at { nil }
      association :plan
      sequence(:stripe_customer_id) { |n| "cus_#{n}#{Faker::Alphanumeric.alphanumeric(number: 8)}" }
      sequence(:stripe_subscription_id) { |n| "sub_#{n}#{Faker::Alphanumeric.alphanumeric(number: 8)}" }
      current_period_end { 30.days.from_now }
    end

    trait :expired_trial do
      status { "trialing" }
      trial_ends_at { 1.day.ago }
    end

    trait :canceled do
      status { "canceled" }
      trial_ends_at { nil }
    end
  end
end

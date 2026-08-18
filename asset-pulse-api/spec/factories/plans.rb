FactoryBot.define do
  factory :plan do
    sequence(:slug) { |n| "plan-#{n}-#{Faker::Alphanumeric.alphanumeric(number: 4)}" }
    name { Faker::Commerce.product_name }
    amount_cents { Faker::Number.between(from: 999, to: 19_999) }
    currency { "usd" }
    interval { "month" }
    ai_enabled { false }
    active { true }
    sequence(:stripe_product_id) { |n| "prod_#{n}#{Faker::Alphanumeric.alphanumeric(number: 8)}" }
    sequence(:stripe_price_id) { |n| "price_#{n}#{Faker::Alphanumeric.alphanumeric(number: 8)}" }
  end
end

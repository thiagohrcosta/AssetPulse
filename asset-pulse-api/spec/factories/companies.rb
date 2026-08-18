FactoryBot.define do
  factory :company do
    association :user
    name { Faker::Company.name }
    sequence(:registration_number) { |n| "#{Faker::Number.number(digits: 10)}#{n}" }
    address_zip_code { Faker::Number.number(digits: 8) }
    address_street { Faker::Address.street_name }
    address_number { Faker::Number.number(digits: 3) }
    address_city { Faker::Address.city }
    address_complement { Faker::Address.secondary_address }
    address_state { Faker::Address.state_abbr }
    company_type { "fleet_operator" }

    trait :repair_shop do
      company_type { "repair_shop" }
    end
  end
end

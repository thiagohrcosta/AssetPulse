FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}_#{Faker::Alphanumeric.alphanumeric(number: 6)}@example.com" }
    password { "P@ssw0rd123" }
    password_confirmation { password }
    full_name { Faker::Name.name }
    sequence(:document_number) { |n| "#{Faker::Number.number(digits: 9)}#{n}" }
    address_zip_code { Faker::Number.number(digits: 8) }
    address_street { Faker::Address.street_name }
    address_number { Faker::Number.number(digits: 3) }
    address_city { Faker::Address.city }
    address_complement { Faker::Address.secondary_address }
    address_state { Faker::Address.state_abbr }
    access { :user }

    trait :admin do
      access { :admin }
    end

    trait :company_admin do
      access { :company_admin }
    end
  end
end

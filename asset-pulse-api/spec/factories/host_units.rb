FactoryBot.define do
  factory :host_unit do
    association :company
    sequence(:vin) { Faker::Vehicle.vin }
    description { Faker::Vehicle.make_and_model }
  end
end

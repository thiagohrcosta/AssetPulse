FactoryBot.define do
  factory :part do
    association :company
    association :part_type_reference
    host_unit { nil }
    sequence(:serial_number) { |n| "#{Faker::Alphanumeric.alphanumeric(number: 10).upcase}#{n}" }
    manufacturer { Faker::Vehicle.manufacture }
    model { Faker::Vehicle.model }
    status { "installed" }
  end
end

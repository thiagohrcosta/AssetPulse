FactoryBot.define do
  factory :part_type_reference do
    sequence(:part_type) { |n| PartTypeReference::PART_TYPES[n % PartTypeReference::PART_TYPES.length] }
    typical_lifespan_days { Faker::Number.between(from: 30, to: 1825) }
  end
end

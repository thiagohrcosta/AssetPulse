FactoryBot.define do
  factory :lifecycle_event do
    association :part
    company { part.company }
    host_unit { nil }
    event_type { "installed" }
    installation_type { "factory_original" }
    occurred_at { Faker::Time.backward(days: 30) }
    age_at_event_days { Faker::Number.between(from: 0, to: 1000) }
    notes { Faker::Lorem.sentence }
  end
end

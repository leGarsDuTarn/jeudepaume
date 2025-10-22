FactoryBot.define do
  factory :constituency do
    sequence(:name) { |n| "Constituency #{n}" }
    level { "circonscription législative" }
    insee_code { nil }

    trait :with_insee do
      sequence(:insee_code) { |n| n.event? ? "2A" : "13009" }
    end
  end
end

FactoryBot.define do
  factory :attendance do
    association :mandate
    # ex: "assembly", "committee", "session"
    scope { "assembly" }
    # ex: "AN_2024_T1"
    scope_ref { nil }

    presence_count { 0 }
    absence_count  { 0 }
    # laissé à nil pour laisser le modèle le calculer
    vote_participation_rate { nil }

    trait :with_ref do
      sequence(:scope_ref) { |n| "REF_#{n}" }
    end

    trait :with_counts do
      presence_count { 42 }
      absence_count  { 8 }
      # le callback calculera environ 84.00
      vote_participation_rate { nil }
    end
  end
end

FactoryBot.define do
  factory :compensation do
    association :mandate
    kind { "base_salary" }
    label { nil }
    period { "monthly" }
    amount_gross_cents { 0 }

    # pour éviter les collisions d'unicité (mandate/kind/label/effective_from)
    sequence(:effective_from) { |n| Date.current - n.days }
    effective_to { nil }
    source { nil }

    trait :with_label do
      sequence(:label) { |n| "Label #{n}" }
    end

    trait :closed do
      effective_to { effective_from + 1.month }
    end

    trait :with_amount do
      amount_gross_cents { 123_456 } # 1234,56 €
    end
  end
end

FactoryBot.define do
  factory :assets_statement do
    association :person

    kind { "declaration" }
    sequence(:filed_on) { |n| Date.current - n.days }  # évite les collisions d’unicité
    total_assets_cents { nil }
    document_url { nil }
    document_meta { nil }

    trait :with_total do
      total_assets_cents { 1_234_56 } # 1 234,56 €
    end

    trait :with_url do
      document_url { "https://example.org/doc.pdf" }
    end
  end
end

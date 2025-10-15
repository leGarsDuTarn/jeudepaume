FactoryBot.define do
  factory :political_group do
    association :institution
    sequence(:name) { |n| "Groupe politique #{n}" }
    short_name { nil }
    color_hex  { nil } 

    # Petits bonus utiles
    trait :with_short_name do
      short_name { "GP" }
    end

    trait :with_color do
      color_hex { "#1a2b3c" }
    end
  end
end

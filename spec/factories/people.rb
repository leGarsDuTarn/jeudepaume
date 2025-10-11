FactoryBot.define do
  factory :person do
    # génération d'un full_name unique avec Faker

    sequence(:full_name) do |n|
      first = Faker::Name.first_name
      last = Faker::Name.last_name
      base = "#{first} #{last}".gsub(/[^\p{L}\p{M}\s\-\'’]/u, "").squish
      "#{base} #{n}"
    end

    # Utilisation de first_name/last_name au lieu de full_name
    trait :with_names do
      full_name { nil }
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
    end

    # Mode admin
    trait :admin_manual do
      after(:build) { |p| p.manual_entry = true }
    end

    # Avec du JSON valide
    trait :with_socials_json do
      socials { { x: "@ben" }.to_json }
    end

    trait :with_external_ids_json do
      external_ids { { an: "PA12345", senat: "S6598" }.to_json }
    end

    trait :with_image_meta_json do
      image_meta { { width: 512, height: 512, credit: "AN" }.to_json }
    end

    # JSON non conforme
    trait :bad_socials do
      socials { "JSON non conforme" }
    end

    # Données formatées
    trait :with_website do
      website { "https://legarsdutarn.test" }
    end

    trait :with_image_url do
      image_url { "https://cdn.exemple.test/photo.jpg" }
    end

    trait :with_birth_place do
      birth_place { "Marseille" }
      birth_postal_code { "13008" }
    end

    trait :male do
      gender { "male" }
    end

    trait :future_birth_date do
      birth_date { Date.today + 1 }
    end

    trait :with_bio do
      bio { "Bio très courte" }
    end
  end
end

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    sequence(:user_name) do |n|
      base = Faker::Internet.username(specifier: [ first_name, last_name ].join, separators: %w(_))

      s = I18n.transliterate(base.to_s.downcase)
        .gsub(/[^a-z0-9_]/, "_")
        .gsub(/_+/, "_")

      s = s[0, 20]
      s = "user_#{n}" if s.length < 3
      s
    end

    sequence(:email) { |n| "user#{n}@gmail.com" }

    password { "Password1!" }
    password_confirmation { "Password1!" }

    # Ici la version avec integer fonctionne 0 = citoyen
    # Mais si l'enum change alors ça casse => + fragile
    # :citoyen => + robuste
    role { :citoyen }

    # Ici 'trait' permet d'être DRY
    # -> évite d'écrire create(:user, role: :admin)
    # -> ça crée une variation réutilisable partout dans les test
    # -> la syntaxe devient create(:user, :admin)
    trait :admin do
      role { :admin }
    end
  end
end

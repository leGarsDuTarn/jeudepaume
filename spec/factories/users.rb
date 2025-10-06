FactoryBot.define do
  factory :user do
    # Permet de générer une adresse mail gmail.com unique
    email { Faker::Internet.unique.email(domain: 'gmail.com') }
    password { "motdepass123" }
    password_confirmation { "motdepass123" }
    # Ici la version avec integer fonctionne 0 = citoyen
    # Mais si l'enum change alors ça casse => + fragile
    # :citoyen => + robuste
    role { :citoyen }
    user_name { Faker::Internet.username }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    # Ici 'trait' permet d'être DRY
    # -> évite d'écrire create(:user, role: :admin)
    # -> ça crée une variation réutilisable partout dans les test
    # -> la syntaxe devient create(:user, :admin)
    trait :admin do
      role { :admin }
    end
  end
end

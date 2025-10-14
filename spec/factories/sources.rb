FactoryBot.define do
  factory :source do
    sequence(:slug) { |n| "src-#{n}" }
    sequence(:url) { |n| "https://example.test/#{n}" }
    association :sourceable, factory: :person
  end
end

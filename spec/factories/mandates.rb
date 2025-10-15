FactoryBot.define do
  factory :mandate do
    association :person
    association :institution
    association :constituency
    role { "Député" }
    started_on { Date.current - 1 }
    status { "en cours" }

    trait :ended do
    ended_on { Date.current - 1 }
    end

    trait :future do
      started_on { Date.current + 10 }
    ended_on { nil }
    end
  end
end

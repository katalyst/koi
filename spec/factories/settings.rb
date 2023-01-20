# frozen_string_literal: true

FactoryBot.define do
  factory :setting do
    string

    key { SecureRandom.uuid }
    label { SecureRandom.uuid }
    role { "Admin" }
    locale { "en" }
    prefix { "page" }

    trait :string do
      field_type { "string" }
      value { Faker::Lorem.word }
    end

    trait :boolean do
      field_type { "boolean" }
      value { "1" }
    end

    trait :text do
      field_type { "text" }
      value { Faker::Lorem.sentence }
    end
  end
end

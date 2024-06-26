# frozen_string_literal: true

FactoryBot.define do
  factory :banner do
    name { Faker::Kpop.solo }
    sequence(:ordinal)
    status { %i[draft published archived].sample }

    trait :with_image do
      image { Rack::Test::UploadedFile.new(Rails.root.join("../fixtures/images/dummy.png"), "image/png") }
    end
  end
end

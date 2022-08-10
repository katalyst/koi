# frozen_string_literal: true

FactoryBot.define do
  factory :navigation_link do
    title { Faker::Beer.hop }
    url { Faker::Internet.unique.url }
  end
end

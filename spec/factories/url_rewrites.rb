# frozen_string_literal: true

FactoryBot.define do
  factory :url_rewrite do
    from { URI.parse(Faker::Internet.url).path }
    to { Faker::Internet.url }
    active { true }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :announcement do
    name { Faker::Book.author }
    title { Faker::Book.title }
    content { Faker::HTML.sandwich }
    active { true }
    published_on { Faker::Date.backward }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :banner do
    name { Faker::Kpop.solo }
    sequence(:ordinal)
  end
end

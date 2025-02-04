# frozen_string_literal: true

FactoryBot.define do
  factory :well_known do
    name { Faker::Internet.base64 }
    purpose { Faker::Lorem.sentence }
    content_type { :text }
    content { Faker::Internet.base64 }
  end
end

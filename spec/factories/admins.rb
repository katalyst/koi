# frozen_string_literal: true

FactoryBot.define do
  factory :admin, class: "Admin" do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    role { "Admin" }
    password { Faker::Internet.password }
    password_confirmation { password }

    trait :god do
      role { "Super" }
    end

    factory :super_admin do
      god
    end
  end
end

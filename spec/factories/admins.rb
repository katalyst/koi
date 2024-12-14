# frozen_string_literal: true

FactoryBot.define do
  factory :admin, class: "Admin::User" do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    password { Faker::Internet.password }
    otp_secret { ROTP::Base32.random }
  end
end

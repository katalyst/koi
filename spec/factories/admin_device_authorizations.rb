# frozen_string_literal: true

FactoryBot.define do
  factory :admin_device_authorization, class: "Admin::DeviceAuthorization" do
    sequence(:device_code_digest) { |n| "digest-#{n}" }
    sequence(:user_code) { |n| "CODE-#{n.to_s.rjust(4, '0')}" }
    status { :pending }
    request_expires_at { 10.minutes.from_now }
    requested_ip { "127.0.0.1" }
    user_agent { "RSpec" }

    trait :approved do
      status { :approved }
      approved_at { Time.current }
      admin_user
    end

    trait :denied do
      status { :denied }
      admin_user
    end

    trait :consumed do
      status { :consumed }
      consumed_at { Time.current }
      admin_user
    end
  end
end

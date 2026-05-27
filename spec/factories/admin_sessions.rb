# frozen_string_literal: true

FactoryBot.define do
  factory :admin_session, class: "Admin::Session" do
    admin
    ip_address { "127.0.0.1" }
    user_agent { "RSpec" }
  end
end

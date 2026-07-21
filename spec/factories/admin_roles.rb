# frozen_string_literal: true

FactoryBot.define do
  factory :admin_role, class: "Admin::Role" do
    sequence(:slug) { |n| "role_#{n}" }
  end
end

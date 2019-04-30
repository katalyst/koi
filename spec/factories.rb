FactoryBot.define do
  factory :admin do
    email { "admin@katalyst.com.au" }
    password { 'not-a-real-password' }
    role { "Super" }
    first_name { "Nicholas" }
    last_name  { "Fury"}
  end

  factory :super_hero do
    name { "Iron Man" }
    description { "Big brain, weak heart" }
    powers { ["FORCE FIELDS"] }
  end

  factory :category do
    name { "Outdoors" }
  end

  factory :product do
    name { "Frisbee" }
    description { "You throw it" }
  end
end

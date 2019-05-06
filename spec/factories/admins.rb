FactoryBot.define do
  factory :admin do
    email { "admin@katalyst.com.au" }
    password { 'not-a-real-password' }
    role { "Super" }
    first_name { "Nicholas" }
    last_name  { "Fury"}
  end
end
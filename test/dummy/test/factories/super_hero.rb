FactoryGirl.define do
  factory :super_hero do |f|
    f.sequence(:name) { |n| "Hero #{n}" }
    f.description    "Hero descripition goes here..."
  end
end

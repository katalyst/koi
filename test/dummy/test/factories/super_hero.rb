FactoryGirl.define do
  factory :super_hero do
    name          { Forgery(:lorem_ipsum).words(10) }
    descripition  { Forgery(:lorem_ipsum).paragraphs(10) }
  end
end

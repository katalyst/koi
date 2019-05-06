FactoryBot.define do
  factory :super_hero do
    transient do
      num_powers { rand(1..SuperHero::Powers.length-1) }
    end

    name { Faker::Name.name }
    powers { SuperHero::Powers.shuffle.take(num_powers) }
    description { Faker::Lorem.sentence }

    factory :iron_man do
      name { "Iron Man" }
      description { "Big brain, weak heart" }
      powers { ["FORCE FIELDS"] }
    end

    factory :captain_america do
      name { "Captain America" }
    end
  end
end
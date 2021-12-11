# frozen_string_literal: true

Koi::Engine.load_seed

generic_hero_details = {
  image: Dragonfly.app.generate(:plasma, 600, 400, "format" => "jpg"),
  file:  Dragonfly.app.generate(:plasma, 50, 50, "format" => "jpg"),
}

100.times.each do
  SuperHero.create!(
    name:        Faker::Superhero.name,
    gender:      SuperHero::GENDERS.sample,
    powers:      SuperHero::POWERS.sample(3),
    url:         Faker::Internet.url,
    telephone:   Faker::PhoneNumber.cell_phone,
    description: Faker::Superhero.descriptor,
    **generic_hero_details,
  )
end

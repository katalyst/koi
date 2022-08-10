# frozen_string_literal: true

FactoryBot.define do
  factory :navigation_menu do
    title { Faker::Beer.unique.name }
    slug { title.parameterize }

    after(:build) do |menu, _context|
      menu.navigation_links.each do |link|
        link.navigation_menu = menu
      end
    end

    after(:create) do |menu, _context|
      items  = menu.navigation_links.map.with_index do |link, index|
        { id: link.id, index: index, depth: 0 }
      end
      latest = menu.build_latest_version(parent: menu, items: items)
      menu.update(current_version: latest)
    end
  end
end

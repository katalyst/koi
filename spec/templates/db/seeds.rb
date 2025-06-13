# frozen_string_literal: true

Koi::Engine.load_seed

FactoryBot.create_list(:announcement, 25) # rubocop:disable FactoryBot/ExcessiveCreateList
FactoryBot.create_list(:announcement, 5, active: false)

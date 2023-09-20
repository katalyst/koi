# frozen_string_literal: true

Koi::Engine.load_seed

FactoryBot.create_list(:post, 25)
FactoryBot.create_list(:post, 5, active: false)

# frozen_string_literal: true

Koi::Engine.load_seed

require_relative "seeds/articles"
ArticleSeeds.run

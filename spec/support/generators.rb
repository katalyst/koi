# frozen_string_literal: true

require "ammeter/init"

module GeneratorHelper
  extend ActiveSupport::Concern

  included do
    # Tell the generator where to put its output (what it thinks of as Rails.root)
    destination Koi::Engine.root.join("tmp/dummy")

    before do
      prepare_destination
    end

    after do
      FileUtils.rm_rf(destination_root)
    end
  end
end

RSpec.configure do |config|
  config.include GeneratorHelper, type: :generator
end

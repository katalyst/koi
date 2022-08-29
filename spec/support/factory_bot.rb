# frozen_string_literal: true

require "factory_bot_rails"

FactoryBot.definition_file_paths << File.expand_path("../factories", __dir__)
FactoryBot.reload

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.append_after do
    FactoryBot.rewind_sequences
    Faker::UniqueGenerator.clear
  end
end

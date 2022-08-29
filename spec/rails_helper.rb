# frozen_string_literal: true

require "spec_helper"
require File.expand_path("dummy/config/environment", __dir__)
require "rspec/rails"

Dir[Koi::Engine.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

begin
  ActiveRecord::Migrator.migrations_paths = File.expand_path("dummy/db/migrate", __dir__)
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)

load "rails/tasks/engine.rake"
load "rails/tasks/statistics.rake"

# prepend test:prepare to run generators, and db:prepare to run migrations
RSpec::Core::RakeTask.new(spec: %w[app:test:prepare app:db:prepare])

RuboCop::RakeTask.new

# dartsass.rake override – compile gem resources instead of dummy app resources
def dartsass_build_mapping
  <<-BUILDS.gsub(/\s+/, " ")
    app/assets/stylesheets/koi/admin.scss:app/assets/builds/koi/admin.css
    app/assets/stylesheets/koi/assets.scss:app/assets/builds/koi/assets.css
    app/assets/stylesheets/koi/nav_items.scss:app/assets/builds/koi/nav_items.css
  BUILDS
end

# compile css before building
task build: "app:dartsass:build"

desc "Run all linters"
task lint: %w[rubocop app:yarn:lint]

desc "Run all auto-formatters"
task format: %w[rubocop:autocorrect app:yarn:format]

task default: %i[lint spec] do
  puts "🎉 build complete! 🎉"
end

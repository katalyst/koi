# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

unless File.exist?("spec/dummy/Rakefile")
  puts "Please run `bin/setup` before running rake tasks"
  exit 1
end

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)

load "rails/tasks/engine.rake"
load "rails/tasks/statistics.rake"

# prepend test:prepare to run generators, and db:prepare to run migrations
RSpec::Core::RakeTask.new(spec: %w[app:spec:prepare])

require "rubocop/katalyst/rake_task"
RuboCop::Katalyst::RakeTask.new

require "rubocop/katalyst/erb_lint_task"
RuboCop::Katalyst::ErbLintTask.new

require "rubocop/katalyst/prettier_task"
RuboCop::Katalyst::PrettierTask.new

namespace :yarn do
  desc "Compile javascript"
  task build: :environment do
    sh "yarn build"
  end
end

desc "Compile assets"
task build: ["yarn:build"]

desc "Run security checks"
task security: :environment do
  sh "bundle exec brakeman -q -w2"
end

task default: %i[lint build spec security] do
  puts "🎉 build complete! 🎉"
end

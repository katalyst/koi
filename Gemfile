# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in katalyst-koi.gemspec.
gemspec

group :development, :test do
  gem "brakeman"
  gem "dartsass-rails"
  gem "erb_lint", require: false
  gem "factory_bot_rails"
  gem "faker"
  gem "katalyst-basic-auth"
  gem "katalyst-healthcheck"
  gem "puma"
  gem "rails", "< 7.1"
  gem "rake"
  gem "rspec-rails"
  gem "rubocop-katalyst", require: false
  gem "sentry-rails"
  gem "shoulda-matchers"
  gem "sprockets-rails"
  gem "sqlite3"
end

group :test do
  gem "capybara"
  gem "cuprite"
  gem "rack_session_access"
  gem "rails-controller-testing"
  gem "webmock"
end

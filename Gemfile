# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in koi.gemspec.
gemspec

gem "katalyst-navigation", path: "../navigation"

group :development, :test do
  gem "brakeman"
  gem "factory_bot_rails"
  gem "faker"
  gem "i18n-active_record", require: "i18n/active_record"
  gem "puma"
  gem "rake"
  gem "rspec-rails"
  gem "rubocop-katalyst", require: false
  gem "shoulda-matchers"
  gem "sqlite3"
end

group :test do
  gem "capybara"
  gem "rails-controller-testing"
end

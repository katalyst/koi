# frozen_string_literal: true

source "http://rubygems.org"

# Declare your gem's dependencies in koi.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# Koi
gem 'koi_config'                , git: 'https://github.com/katalyst/koi_config.git'

gem 'ornament', github: 'katalyst/ornament', branch: 'master'

gem 'sass-rails', '~> 5.0.0'
gem 'webpacker', '~> 3.0'
gem 'react_on_rails', '~> 11.1.4'
gem 'pg', '~> 1.1.0'

gem 'tzinfo-data', platforms: ['mingw', 'mswin']
gem 'better_errors'
gem 'foreman'

group :development, :test do
  gem 'guard-rspec', require: false
  gem 'factory_bot_rails'
  gem "database_cleaner"
  gem "pry-rails"
  gem 'rspec-rails'
  gem 'shoulda-matchers'
end

group :test do
  gem "capybara"
  gem 'orderly'
  gem 'launchy'
  gem "poltergeist"
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'faker'
end

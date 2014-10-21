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

# i18n ActiveRecord backend
gem 'i18n-active_record'        , git: 'https://github.com/svenfuchs/i18n-active_record.git',
                                  branch: 'rails-3.2',
                                  require: 'i18n/active_record'

gem 'pg'
gem 'pry'
gem 'better_errors'
gem 'binding_of_caller'

gem 'ornament', github: 'katalyst/ornament', branch: 'feature/development'
gem "compass-rails", "~> 1.1.7"


# gem 'puma'
gem 'unicorn'
gem 'passenger'
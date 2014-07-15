source "http://rubygems.org"

# Declare your gem's dependencies in koi.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# jQuery
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 4.2.1'

# Nested fields
gem 'awesome_nested_fields'     , git: 'https://github.com/katalyst/awesome_nested_fields.git'

# Koi
gem 'koi_config'                , git: 'https://github.com/katalyst/koi_config.git'

# Bowerbird
gem 'bowerbird_v2'              , git: 'https://github.com/katalyst/bowerbird_v2.git'

# i18n ActiveRecord backend
gem 'i18n-active_record'        , git: 'https://github.com/svenfuchs/i18n-active_record.git',
                                  branch: 'rails-3.2',
                                  require: 'i18n/active_record'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'              , '~> 3.1'
  gem 'uglifier'                , '>= 1.0.3'
  gem 'coffee-rails'
end

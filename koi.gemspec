$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "koi/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = "koi"
  s.version       = Koi::VERSION
  s.authors       = ["Rahul Trikha"]
  s.email         = ["rahul@katalyst.com.au"]
  s.homepage      = "https://github.com/katalyst/koi"
  s.summary       = "Koi CMS admin framework"
  s.description   = "Framework to provide rapid application development"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # MVC Framework
  s.add_dependency 'rails'                         , "~> 3.2.1"

  # Overwrite for default rails
  s.add_dependency 'jquery-rails'

  # Database
  s.add_dependency 'mysql2'                        , '~> 0.3.11'

  # Authorization
  s.add_dependency 'devise'                        , '~> 2.0.1'
  s.add_dependency 'cancan'                        , '~> 1.6.7'

  # Form
  s.add_dependency 'simple_form'                   , '~> 1.5.2'

  # Tree
  s.add_dependency 'nested_set'                    , '~> 1.6.8'

  # Mailer
  s.add_dependency 'sendgrid'                      , '~> 1.0.1'

  # File Handling
  s.add_dependency 'dragonfly'                     , '~> 0.9.9'

  # User Friendly Slugs
  s.add_dependency 'friendly_id'                   , '~> 4.0.0'

  # Pagination
  s.add_dependency 'kaminari'                      , '~> 0.13.0'

  # Data Seeding
  s.add_dependency 'seedbank'                      , '~> 0.0.7'

  # Easier SQL Queries
  s.add_dependency 'squeel'                        , '~> 0.9.3'

  # Inherited Resources
  s.add_dependency 'inherited_resources'           , '~> 1.3.0'
  s.add_dependency 'has_scope'                     , '~> 0.5.1'
  s.add_dependency 'responders'                    , '~> 0.6.4'

  # Navigation Rendering
  s.add_dependency 'simple-navigation'             , '~> 3.6.0'

  # Tags
  s.add_dependency 'acts-as-taggable-on'           , '~> 2.2.0'

  # Scoped Search
  s.add_dependency 'scoped_search'                 , '~> 2.3.6'

  # Association Patterns
  s.add_dependency 'has'                           , '~> 1.0.3'

  # i18n ActiveRecord backend
  s.add_dependency 'i18n-active_record'

  # Deployment
  s.add_dependency 'engineyard'

  # New Relic
  s.add_dependency 'newrelic_rpm'

  # Unique ID generation
  s.add_dependency 'uuidtools'                     , '~> 2.1.2'

  # Google Analytics
  s.add_dependency 'garb'

  # Fixture replacement
  s.add_dependency 'factory_girl_rails'            , '1.2.0'

  # Console Replacement
  s.add_development_dependency 'pry'               , '~> 0.9.7'

  # Powder makes POW easy
  s.add_development_dependency 'powder'            , '0.1.7'

  # Clever Data Generator
  s.add_development_dependency 'forgery'

  # Guard for automated testing
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-test'
  s.add_development_dependency 'guard-livereload'
  s.add_development_dependency 'ruby_gntp'
end

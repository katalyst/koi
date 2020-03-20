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
  s.require_paths = ["lib"]

  # MVC Framework
  s.add_dependency 'rails'                         , '~> 3.2.16'

  # Overwrite for default rails
  s.add_dependency 'jquery-rails'                  , '~> 3.1.1'

  # jQuery UI
  s.add_dependency 'jquery-ui-rails'               , '~> 4.2.1'

  # Authorization
  s.add_dependency 'devise'                        , '~> 3.2.4'

  # Form
  s.add_dependency 'simple_form'                   , '~> 2.1.0'

  # Tree
  s.add_dependency 'nested_set'                    , '~> 1.7.0'

  # Mailer
  s.add_dependency 'sendgrid'                      , '~> 1.2.0'

  # File Handling
  s.add_dependency 'dragonfly'                     , '~> 0.9.9'

  # User Friendly Slugs
  s.add_dependency 'friendly_id'                   , '~> 4.0.0'

  # Pagination
  s.add_dependency 'kaminari'                      , '~> 0.14.0'

  # Inherited Resources
  s.add_dependency 'inherited_resources'           , '~> 1.4.1'
  s.add_dependency 'has_scope'
  s.add_dependency 'responders'

  # Navigation Rendering
  s.add_dependency 'simple-navigation'             , '~> 3.11.0'

  # Tags
  s.add_dependency 'acts-as-taggable-on'           , '~> 2.4.1'

  # Scoped Search
  s.add_dependency 'scoped_search'                 , '~> 2.6.0'

  # Association Patterns
  s.add_dependency 'has'                           , '~> 1.0.3'

  # Unique ID generation
  s.add_dependency 'uuidtools'                     , '~> 2.1.2'

  # Google Analytics
  s.add_dependency 'garb'

  # Validators
  s.add_dependency 'activevalidators'              , '~> 2.0.1'

  # Redis
  s.add_dependency 'redis'

  # Sidekiq (Background Server)
  s.add_dependency 'sidekiq'

  # Required by Sidekiq Web
  s.add_dependency 'sinatra'                       , '>= 1.3.0'

  # Nice Multi Select
  s.add_dependency 'select2-rails'

  # Nested Forms
  s.add_dependency 'cocoon'

  # Coffee Script
  s.add_dependency 'coffee-rails'

  # Figaro for using ENV variables
  s.add_dependency 'figaro'

  # Admin Graphing
  s.add_dependency 'rickshaw_rails'
end

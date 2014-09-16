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

  s.add_dependency 'mime-types', '~> 2.3'
  # MVC Framework
  s.add_dependency 'rails', '~> 4.1.6'

  s.add_dependency 'rails-observers'

  s.add_dependency 'protected_attributes'

  s.add_dependency 'sass-rails'

  s.add_dependency 'uglifier'

  s.add_dependency 'bootstrap-sass', "2.0.4.2"

  # Overwrite for default rails
  s.add_dependency 'jquery-rails'

  # jQuery UI
  s.add_dependency 'jquery-ui-rails'

  # Authorization
  s.add_dependency 'devise'

  # Form
  s.add_dependency 'simple_form'

  # Tree
  s.add_dependency 'awesome_nested_set'

  # Mailer
  s.add_dependency 'sendgrid'

  # File Handling
  s.add_dependency 'dragonfly'

  # User Friendly Slugs
  s.add_dependency 'friendly_id'

  # Pagination
  s.add_dependency 'kaminari'

  # Inherited Resources
  s.add_dependency 'inherited_resources'
  s.add_dependency 'has_scope', '0.6.0.rc'
  s.add_dependency 'responders'

  # Navigation Rendering
  s.add_dependency 'simple-navigation'

  # Tags
  s.add_dependency 'acts-as-taggable-on'

  # Scoped Search
  s.add_dependency 'scoped_search'

  # Association Patterns
  s.add_dependency 'has'

  # Unique ID generation
  s.add_dependency 'uuidtools'

  # Google Analytics
  s.add_dependency 'garb'

  # Validators
  s.add_dependency 'activevalidators'

  # Redis
  s.add_dependency 'redis'

  # Sidekiq (Background Server)
  s.add_dependency 'sidekiq'

  # Required by Sidekiq Web
  s.add_dependency 'sinatra'

  # Nice Multi Select
  s.add_dependency 'select2-rails'

  # Nested Forms
  s.add_dependency 'cocoon'

  # Figaro for using ENV variables
  s.add_dependency 'figaro'

  # Admin Graphing
  s.add_dependency 'countries'

  # Admin Graphing
  s.add_dependency 'rickshaw_rails'

  # Karo Asset Syncer
  s.add_development_dependency 'karo'

  # Console Replacement
  s.add_development_dependency 'pry-rails'

  # Powder makes POW easy
  s.add_development_dependency 'powder'

  # Clever Data Generator
  s.add_development_dependency 'forgery'

  # Data Seeding
  s.add_development_dependency 'seedbank'

  # Fixture replacement
  s.add_development_dependency 'factory_girl_rails'

  # Error display Replacement
  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'binding_of_caller'

  # Guard for automated testing
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-test'
  s.add_development_dependency 'guard-livereload'
  s.add_development_dependency 'ruby_gntp'
end

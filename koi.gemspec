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

  s.add_dependency 'mime-types'#, '~> 2.3'

  s.add_dependency 'rails', '~> 5.0.1'

  # s.add_dependency 'rails-observers'

  s.add_dependency 'active_model_serializers'#, '~> 0.8.2'

  s.add_dependency 'pg'

  s.add_dependency 'compass-rails'#, '~> 2.0.2'

  s.add_dependency 'compass'#, '~> 1.0.0'

  s.add_dependency 'uglifier'

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

  s.add_dependency 'has_scope'#, '0.6.0.rc'
  s.add_dependency 'responders'#, '~> 2.1'

  # Navigation Rendering
  s.add_dependency 'simple-navigation'#, '~> 3.14.0'

  # Tags
  s.add_dependency 'acts-as-taggable-on'

  # Scoped Search
  s.add_dependency 'scoped_search'#, '~> 3.2.0'

  # Unique ID generation
  s.add_dependency 'uuidtools'

  # Google Analytics
  s.add_dependency 'garb'

  # Validators
  s.add_dependency 'activevalidators'#, '~> 3.2.0'

  # Redis
  s.add_dependency 'redis'

  # Sidekiq (Background Server)
  s.add_dependency 'sidekiq'

  # # Required by Sidekiq Web
  # s.add_dependency 'sinatra'

  # Nice Multi Select
  s.add_dependency 'select2-rails'

  # Nested Forms
  s.add_dependency 'cocoon'

  # Admin Graphing
  s.add_dependency 'countries'

  # Admin Graphing
  s.add_dependency 'rickshaw_rails'

  # Application Settings
  s.add_dependency 'figaro'

  # Development Dependencies
  s.add_development_dependency 'karo'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'pry-rails'
  # s.add_development_dependency 'web-console'#, '~> 2.0'
end

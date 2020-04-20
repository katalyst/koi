$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require 'koi/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = 'koi'
  s.version       = Koi::VERSION
  s.authors       = ['Rahul Trikha', 'Bill Pearce', 'Matt Redmond']
  s.email         = ['rahul@katalyst.com.au', 'bill@katalyst.com.au', 'matt@katalyst.com.au']
  s.homepage      = 'https://github.com/katalyst/koi'
  s.summary       = 'Koi CMS admin framework'
  s.description   = 'Framework to provide rapid application development'

  s.files         =  Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'mime-types'

  s.add_dependency 'rails', '< 7'

  s.add_dependency 'active_model_serializers'

  s.add_dependency 'pg'

  s.add_dependency 'compass-rails'

  s.add_dependency 'compass'

  s.add_dependency 'uglifier'

  # Overwrite for default rails
  s.add_dependency 'jquery-rails'

  # jQuery UI
  s.add_dependency 'jquery-ui-rails'

  # Authorization
  s.add_dependency 'devise'

  # Form
  s.add_dependency 'simple_form'

  # Nav items (tree structure)
  s.add_dependency 'awesome_nested_set'

  # Mailer
  s.add_dependency 'sendgrid'

  # File Handling
  s.add_dependency 'dragonfly'

  # User Friendly Slugs
  s.add_dependency 'friendly_id'

  # Pagination
  s.add_dependency 'kaminari'

  s.add_dependency 'has_scope'
  s.add_dependency 'responders'

  # Navigation Rendering
  s.add_dependency 'simple-navigation'

  # Tags
  s.add_dependency 'acts-as-taggable-on'

  # Scoped Search
  s.add_dependency 'scoped_search'

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

  # Puma server
  s.add_dependency 'puma'

  s.add_dependency 'inherited_resources'

  s.add_dependency 'htmlentities'

  # React for composable pages
  s.add_dependency 'react-rails'
end

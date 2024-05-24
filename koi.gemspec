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
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'mime-types', '~> 3.1'

  s.add_dependency 'rails', '~> 5.2.3'

  s.add_dependency 'active_model_serializers', '~> 0.10.6'

  s.add_dependency 'compass-rails', '~> 3.0.2'

  s.add_dependency 'compass', '~> 1.0.3'

  s.add_dependency 'uglifier', '~> 3.2.0'

  # Overwrite for default rails
  s.add_dependency 'jquery-rails', '~> 4.3.1'

  # jQuery UI
  s.add_dependency 'jquery-ui-rails', '~> 6.0.1'

  # Authorization
  s.add_dependency 'devise', '~> 4.6.2'

  # Form
  s.add_dependency 'simple_form', '~> 4.1.0'

  # Nav items (tree structure)
  s.add_dependency 'awesome_nested_set', '~> 3.1.3'

  # Mailer
  s.add_dependency 'sendgrid', '~> 1.2.4'

  # File Handling
  s.add_dependency 'dragonfly', '~> 1.1.2'

  # User Friendly Slugs
  s.add_dependency 'friendly_id', '~> 5.2.1'

  # Pagination
  s.add_dependency 'kaminari', '~> 1.0.1'

  s.add_dependency 'has_scope', '~> 0.7.1'
  s.add_dependency 'responders', '~> 2.4.0'

  # Navigation Rendering
  s.add_dependency 'simple-navigation', '~> 3.14'

  # Tags
  s.add_dependency 'acts-as-taggable-on', '~> 6.0.0'

  # Scoped Search
  s.add_dependency 'scoped_search', '~> 4.1.0'

  # Unique ID generation
  s.add_dependency 'uuidtools', '~> 2.1.5'

  # Google Analytics
  s.add_dependency 'garb', '~> 0.9.8'

  # Validators
  s.add_dependency 'activevalidators', '~> 4.0.2'

  # Redis
  s.add_dependency 'redis', '~> 3.3.3'

  # Sidekiq (Background Server)
  s.add_dependency 'sidekiq', '~> 5.0.0'

  # Nice Multi Select
  s.add_dependency 'select2-rails', '~> 3.5.9'

  # Nested Forms
  s.add_dependency 'cocoon', '~> 1.2.10'

  # Admin Graphing
  s.add_dependency 'countries', '~> 1.2.5'

  # Admin Graphing
  s.add_dependency 'rickshaw_rails', '~> 1.4.5'

  # Application Settings
  s.add_dependency 'figaro', '~> 1.1.1'

  # Puma server
  s.add_dependency 'puma', '~> 3.12.1'

  s.add_dependency 'inherited_resources', '~> 1.10.0'

  s.add_dependency 'htmlentities', '~> 4.3.4'

  # React for composable pages
  s.add_dependency 'react_on_rails', '~> 11.1.4'

  # Development Dependencies
  s.add_development_dependency 'karo'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'engineyard'
end

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

  s.add_dependency "rails", "~> 4.2.1"

  s.add_dependency "sass-rails", "~> 5.0.0"

  s.add_dependency "sass", "~> 3.4.12"

  # Overwrite for default rails
  s.add_dependency "jquery-rails"

  # jQuery UI
  s.add_dependency "jquery-ui-rails"

  # Authorization
  s.add_dependency "devise"

  # Form
  s.add_dependency "simple_form"

  # Tree
  s.add_dependency "awesome_nested_set"

  # Mailer
  s.add_dependency "sendgrid"

  # File Handling
  s.add_dependency "dragonfly"

  # User Friendly Slugs
  s.add_dependency "friendly_id"

  # Pagination
  s.add_dependency "kaminari"

  # Inherited Resources
  s.add_dependency "inherited_resources", "~> 1.6"
  s.add_dependency "has_scope", "0.6.0.rc"

  # Navigation Rendering
  s.add_dependency "simple-navigation", "~> 3.14.0"

  # Tags
  s.add_dependency "acts-as-taggable-on"

  # Scoped Search
  s.add_dependency "scoped_search", "~> 3.2.0"

  # Nice Multi Select
  s.add_dependency "select2-rails"

  # Nested Forms
  s.add_dependency "cocoon"
end

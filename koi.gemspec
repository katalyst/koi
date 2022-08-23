# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "koi/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name          = "koi"
  s.version       = Koi::VERSION
  s.authors       = ["Katalyst"]
  s.email         = ["admin@katalyst.com.au"]
  s.homepage      = "https://github.com/katalyst/koi"
  s.summary       = "Koi CMS admin framework"
  s.description   = "Framework to provide rapid application development"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency "rails", ">= 6.1"

  # Import maps for ES6 JS
  s.add_dependency "importmap-rails"

  # Hotwire JS dependencies
  s.add_dependency "stimulus-rails"
  s.add_dependency "turbo-rails"

  # CSS compilation
  s.add_dependency "sass-rails", ">= 6"

  # Overwrite for default rails
  s.add_dependency "jquery-rails", ">= 4.4"

  # jQuery UI
  s.add_dependency "jquery-ui-rails", ">= 6"

  # Authorization
  # # devise 4.8.0 supports rails 6.1
  s.add_dependency "devise", ">= 4.8.0"

  # Form
  # simple_form v5.1.0 supports rails 6.1
  s.add_dependency "simple_form", ">= 5.1.0"

  # Tree
  # awesome_nested_set v3.3.0 supports rails 6.1
  s.add_dependency "awesome_nested_set", ">= 3.3.0"

  # File Handling
  s.add_dependency "dragonfly", "= 1.3.0"

  # User Friendly Slugs
  s.add_dependency "friendly_id"

  # Pagination
  s.add_dependency "kaminari", ">= 1.2.1"

  # Inherited Resources
  s.add_dependency "has_scope", ">= 0.8"
  s.add_dependency "inherited_resources", ">= 1.13.0"

  # Navigation Rendering
  s.add_dependency "simple-navigation", "~> 3.14.0"

  # Tags
  s.add_dependency "acts-as-taggable-on", ">= 7.0.0"

  # Scoped Search
  s.add_dependency "scoped_search", ">= 4.1.8"

  # Nice Multi Select
  s.add_dependency "select2-rails", ">= 4"

  # Nested Forms
  s.add_dependency "cocoon", ">= 1.2.15"

  # Index tables
  s.add_dependency "katalyst-tables"

  # Allow non-digest references to assets (ckeditor)
  s.add_dependency "non-digest-assets"

  s.add_dependency "flipper"
  s.add_dependency "flipper-active_record"
  s.add_dependency "flipper-ui"

  # Settings
  s.add_dependency "i18n-active_record"
  s.metadata = {
    "rubygems_mfa_required" => "true",
  }
end

# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "koi/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "koi"
  s.version     = Koi::VERSION
  s.authors     = ["Katalyst"]
  s.email       = ["admin@katalyst.com.au"]
  s.homepage    = "https://github.com/katalyst/koi"
  s.summary     = "Koi CMS admin framework"
  s.description = "Framework to provide rapid application development"

  s.required_ruby_version = ">= 3.1.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency "rails", ">= 7.0"

  # Import maps for ES6 JS
  s.add_dependency "importmap-rails"

  # Hotwire JS dependencies
  s.add_dependency "stimulus-rails"
  s.add_dependency "turbo-rails"

  # Overwrite for default rails
  s.add_dependency "jquery-rails", ">= 4.4"

  # jQuery UI
  s.add_dependency "jquery-ui-rails", ">= 6"

  # Authorization
  s.add_dependency "bcrypt"

  # Form builder for admin crud
  s.add_dependency "katalyst-govuk-formbuilder"

  # Pagination
  s.add_dependency "pagy"

  # Nice Multi Select
  s.add_dependency "select2-rails", ">= 4"

  # Index tables
  s.add_dependency "katalyst-tables"

  # Navigation
  s.add_dependency "katalyst-navigation"

  # Content
  s.add_dependency "katalyst-content"

  s.metadata = {
    "rubygems_mfa_required" => "true",
  }
end

# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "koi/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "katalyst-koi"
  s.version     = Koi::VERSION
  s.authors     = ["Katalyst Interactive"]
  s.email       = ["developers@katalyst.com.au"]

  s.summary     = "Koi CMS admin framework"
  s.homepage    = "https://github.com/katalyst/koi"
  s.license     = "MIT"
  s.required_ruby_version = ">= 3.1"

  s.files         = Dir["{app,config,db,lib}/**/*", "spec/factories/**/*", "MIT-LICENSE", "README.md", "Upgrade.md"]
                      .reject { |f| f =~ %r{^lib/tasks} }
  s.require_paths = ["lib"]
  s.metadata["rubygems_mfa_required"] = "true"

  s.add_dependency "rails", ">= 7.0"

  # Import maps for ES6 JS
  s.add_dependency "importmap-rails"

  # Hotwire JS dependencies
  s.add_dependency "stimulus-rails"
  s.add_dependency "turbo-rails"

  # Authorization
  s.add_dependency "bcrypt"
  s.add_dependency "webauthn"

  # Third party libraries for admin pages
  s.add_dependency "katalyst-govuk-formbuilder"
  s.add_dependency "pagy"
  s.add_dependency "view_component"

  # Katalyst libraries
  s.add_dependency "katalyst-content"
  s.add_dependency "katalyst-kpop"
  s.add_dependency "katalyst-navigation"
  s.add_dependency "katalyst-tables"
end
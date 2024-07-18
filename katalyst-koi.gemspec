# frozen_string_literal: true

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "katalyst-koi"
  s.version     = "4.10.3"
  s.authors     = ["Katalyst Interactive"]
  s.email       = ["developers@katalyst.com.au"]

  s.summary     = "Koi CMS admin framework"
  s.homepage    = "https://github.com/katalyst/koi"
  s.license     = "MIT"
  s.required_ruby_version = ">= 3.2"

  s.files         = Dir["{app,config,db,lib}/**/*", "spec/factories/**/*", "MIT-LICENSE", "README.md", "Upgrade.md"]
                      .grep_v(%r{^lib/tasks})
  s.require_paths = ["lib"]
  s.metadata["rubygems_mfa_required"] = "true"

  s.add_dependency "rails", ">= 7.1"

  # Import maps for ES6 JS
  s.add_dependency "importmap-rails"

  # Hotwire JS dependencies
  s.add_dependency "stimulus-rails"
  s.add_dependency "turbo-rails", ">= 2.0"

  # Authorization
  s.add_dependency "bcrypt"
  s.add_dependency "webauthn"

  # Third party libraries for admin pages
  s.add_dependency "katalyst-govuk-formbuilder", ">= 1.9"
  s.add_dependency "pagy", ">= 8.0"
  s.add_dependency "view_component"

  # Katalyst libraries
  s.add_dependency "katalyst-content"
  s.add_dependency "katalyst-html-attributes"
  s.add_dependency "katalyst-kpop", ">= 3.1"
  s.add_dependency "katalyst-navigation"
  s.add_dependency "katalyst-tables"
end

# frozen_string_literal: true

# Run using bin/ci

CI.run do
  step "Style", "bundle exec rake lint"
  step "Assets: Build", "bundle exec rake build"
  step "Tests: RSpec", "bundle exec rake spec"
  step "Security: Brakeman", "bundle exec rake security"
end

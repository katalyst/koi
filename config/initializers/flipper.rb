# frozen_string_literal: true

# Register koi admin roles with flipper for easy toggling

return unless Object.const_defined?("Flipper")

Flipper.register(:admins) do |flipper, _context|
  flipper.actor.is_a?(Admin::User) && !flipper.actor.archived?
end

Admin::User.include(Flipper::Identifier)

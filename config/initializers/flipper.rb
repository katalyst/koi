# frozen_string_literal: true

# Register koi admin roles with flipper for easy toggling

return unless Object.const_defined?("Flipper")

Flipper.register(:admins) do |actor, _context|
  actor.respond_to?("role") && ((actor.role.eql? "Admin") || (actor.role.eql? "Super"))
end

Flipper.register(:super_admins) do |actor, _context|
  actor.respond_to?("role") && (actor.role.eql? "Super")
end

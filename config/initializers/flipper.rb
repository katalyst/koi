# frozen_string_literal: true

# Register koi admin roles with flipper for easy toggling
Rails.application.config.to_prepare do
  next unless Object.const_defined?("Flipper")

  Flipper.register(:admins) do |actor, _context|
    actor.respond_to?("role") && ((actor.role.eql? "Admin") || (actor.role.eql? "Super"))
  end

  Flipper.register(:super_admins) do |actor, _context|
    actor.respond_to?("role") && (actor.role.eql? "Super")
  end
end

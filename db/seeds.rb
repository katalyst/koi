# frozen_string_literal: true

# Create a default admin user (only in development)
if Rails.env.development? && !ENV["CI"]
  Admin::User.create_with(
    name: `id -F`.strip,
  ).find_or_create_by(email: "#{ENV.fetch('USER', nil)}@katalyst.com.au")
end

# frozen_string_literal: true

require "securerandom"
require "thor"
thor = Thor::Shell::Basic.new

unless AdminUser.find_by(email: "admin@katalyst.com.au")
  password = SecureRandom.base58(16)

  thor.say("Your admin@katalyst.com.au password has been set to #{password}, please update your password manager",
           :green)

  # Default Super admin
  AdminUser.create(first_name: "Admin", last_name: "Katalyst", email: "admin@katalyst.com.au",
                   role: "Super", password: password, password_confirmation: password)
end

# frozen_string_literal: true

require "dragonfly"

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

Rails.application.config.to_prepare do
  # Add model functionality
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.extend Dragonfly::Model
    ActiveRecord::Base.extend Dragonfly::Model::Validations
  end
end

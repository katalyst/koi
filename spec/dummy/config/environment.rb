# frozen_string_literal: true

# Load the rails application
require File.expand_path("application", __dir__)

# Initialize the rails application
Dummy::Application.initialize!

# Set the default host and port to be the same as Action Mailer.
Rails.application.routes.default_url_options = Rails.application.config.action_mailer.default_url_options

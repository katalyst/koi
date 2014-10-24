require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  verify_urls false

  secret "30b253535467d3d782c7b5c5fc83a4ca061e5b69f2e2c4a9e617e62f981280fe"

  url_format "/media/:job/:name"

  datastore :file,
    root_path: Rails.root.join('public/system/dragonfly', Rails.env),
    server_root: Rails.root.join('public')
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end

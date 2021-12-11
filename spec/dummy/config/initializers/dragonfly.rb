# frozen_string_literal: true

require "dragonfly"

Dragonfly.app.configure do
  plugin :imagemagick

  verify_urls true

  secret Rails.application.credentials.dragonfly_secret

  url_format "/media/:job/:name"

  before_serve do |job, _env|
    Rails.logger.info("<Dragonfly Processing> uncached file #{job.inspect}")
    ProcessedAsset.find_or_create_by(uid: job.store, signature: job.signature)
  end
end

# Configure Image Assets
Dragonfly.app(:image).configure do
  plugin :imagemagick

  verify_urls true

  secret Rails.application.credentials.dragonfly_secret

  url_format "/media/:job/:name"

  define_url do |app, job, _opts|
    thumb = ProcessedAsset.find_by(signature: job.signature)
    if thumb
      app.remote_url_for(thumb.uid)
    else
      app.server.url_for(job)
    end
  end
end

# Configure File Assets
Dragonfly.app(:file).configure do
  verify_urls true

  secret Rails.application.credentials.dragonfly_secret

  url_format "/media/:job/:name"

  define_url do |app, job, _opts|
    app.remote_url_for(job.uid)
  end
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

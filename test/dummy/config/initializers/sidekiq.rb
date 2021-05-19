default_config = { namespace: Rails.application.class.module_parent.downcase }

Sidekiq.configure_server do |config|
  config.redis = default_config
end

Sidekiq.configure_client do |config|
  config.redis = default_config
end

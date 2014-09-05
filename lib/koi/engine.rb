require_relative 'middleware/url_redirect'

module Koi
  class Engine < ::Rails::Engine

    isolate_namespace Koi

    config.active_record.observers = :expire_cache_observer

    initializer 'static assets' do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
      # app.middleware.insert_before "Rack::Cache", Koi::UrlRedirect
    end

  end
end

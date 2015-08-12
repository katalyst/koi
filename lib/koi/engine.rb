require_relative 'middleware/url_redirect'

module Koi
  class Engine < ::Rails::Engine

    isolate_namespace Koi

    config.active_record.observers = :expire_cache_observer

    initializer 'static assets' do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
      app.middleware.insert_before "Rack::Sendfile", Koi::UrlRedirect
      app.config.assets.precompile += %w(modernizr.js selectivizr.js css3-mediaqueries.js application_bottom.js koi.js koi/nav_items.js koi/assets.js)
    end

  end
end

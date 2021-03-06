require_relative "middleware/url_redirect"

module Koi
  class Engine < ::Rails::Engine

    isolate_namespace Koi

    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
      app.middleware.insert_before Rack::Sendfile, Koi::UrlRedirect
      app.config.assets.precompile += %w(
        koi.js
        koi/nav_items.js
        koi/assets.js
        koi/application.css
        koi/ckeditor.js
      )
    end

  end
end

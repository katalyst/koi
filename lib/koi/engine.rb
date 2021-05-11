require_relative "middleware/url_redirect"

module Koi
  class Engine < ::Rails::Engine

    isolate_namespace Koi

    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
      app.middleware.use Koi::UrlRedirect
      app.config.assets.precompile += %w(
        koi/modernizr.js
        selectivizr.js
        css3-mediaqueries.js
        application_bottom.js
        koi.js
        koi/nav_items.js
        koi/assets.js
        koi/application/placeholder-image-none.png
        koi/application.css
      )
    end

  end
end

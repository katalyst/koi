require_relative "middleware/url_redirect"

module Koi
  class Engine < ::Rails::Engine

    isolate_namespace Koi

    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
      app.middleware.use Koi::UrlRedirect
      app.config.assets.precompile += %w(
        koi.js
        koi/nav_items.js
        koi/assets.js
        koi/application.css
        koi/modernizr.js
        koi/selectivizr.js
        koi/css3-mediaqueries.js
        koi/ckeditor.js
      )
    end

  end
end

require_relative 'middleware/url_redirect'

module Koi
  class Engine < ::Rails::Engine

    isolate_namespace Koi

    initializer 'static assets' do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
      app.middleware.insert_before Rack::Sendfile, Koi::UrlRedirect
      app.config.assets.precompile += %w(koi/modernizr.js selectivizr.js css3-mediaqueries.js application_bottom.js koi.js koi/nav_items.js koi/assets.js koi/application/logo-katalyst.png koi/application/logo-katalyst-devise.png)
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end
  end
end

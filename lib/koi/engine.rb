require_relative 'middleware/url_redirect'

module Koi
  class Engine < ::Rails::Engine

    isolate_namespace Koi

    initializer 'static assets' do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
      app.middleware.insert_before "Rack::Cache", Koi::UrlRedirect
    end

  end
end

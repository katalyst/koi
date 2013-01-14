module Koi
  class Engine < ::Rails::Engine
    isolate_namespace Koi
    initializer 'static assets' do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
#     app.middleware.insert_before ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
    end
  end
end

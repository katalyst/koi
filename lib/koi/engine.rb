# frozen_string_literal: true

require_relative "middleware/url_redirect"

module Koi
  class Engine < ::Rails::Engine
    engine_name "koi"

    initializer "koi.assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
      app.middleware.insert_before Rack::Sendfile, Koi::UrlRedirect

      config.after_initialize do |a|
        if a.config.respond_to?(:assets)
          a.config.assets.precompile += %w(koi.js)
        end
      end
    end

    initializer "koi.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << root.join("app/assets/javascripts")
    end

    initializer "koi.factories", after: "factory_bot.set_factory_paths" do
      FactoryBot.definition_file_paths << Engine.root.join("spec/factories") if defined?(FactoryBot)
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: "spec/factories"
    end
  end
end

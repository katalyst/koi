# frozen_string_literal: true

require "importmap-rails"
require "katalyst/content"
require "katalyst/govuk/formbuilder"
require "katalyst/kpop"
require "katalyst/navigation"
require "katalyst/tables"
require "pagy"
require "stimulus-rails"
require "turbo-rails"
require "webauthn"

module Koi
  class Engine < ::Rails::Engine
    engine_name "koi"
    config.eager_load_namespaces << Koi
    config.paths.add("lib", autoload_once: true, exclude: %w[lib/generators lib/tasks])

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: "spec/factories"
    end

    initializer "koi.assets" do |app|
      app.config.after_initialize do |_|
        if app.config.respond_to?(:assets)
          app.config.assets.precompile += %w(koi.js)
        end
      end
    end

    initializer "koi.content" do
      Katalyst::Content.config.base_controller  = "Admin::ApplicationController"
      Katalyst::Content.config.errors_component = "Koi::Content::Editor::ErrorsComponent"
    end

    initializer "koi.factories", after: "factory_bot.set_factory_paths" do
      FactoryBot.definition_file_paths << root.join("spec/factories")
    end

    initializer "koi.forms", after: "factory_bot.set_factory_paths" do
      GOVUKDesignSystemFormBuilder::Builder.include(Koi::Form::GOVUKExtensions)
    end

    initializer "koi.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << root.join("app/assets/javascripts")
    end

    initializer "koi.middleware" do |app|
      app.middleware.use ::ActionDispatch::Static, root.join("public").to_s
      app.middleware.insert_before Rack::Sendfile, Koi::Middleware::UrlRedirect
    end

    initializer "koi.navigation" do
      Katalyst::Navigation.config.base_controller  = "Admin::ApplicationController"
      Katalyst::Navigation.config.errors_component = "Koi::Navigation::Editor::ErrorsComponent"
    end

    initializer "koi.pagination" do
      Pagy::I18n.load(locale: "en", filepath: root.join("config/locales/pagy.en.yml"))
    end

    initializer "koi.tables" do
      Katalyst::Tables.config.collection_types[:archivable] = "Koi::Collection::Type::Archivable"
    end

    initializer "koi.views" do
      ActiveSupport.on_load(:action_view) do
        # Workaround for de-duplicating nested module paths for admin controllers
        # https://github.com/rails/rails/issues/50916
        ActionView::AbstractRenderer::ObjectRendering.define_method(
          :merge_prefix_into_object_path,
          Koi::Extensions::ObjectRendering.instance_method(:merge_prefix_into_object_path),
        )
      end
    end
  end
end

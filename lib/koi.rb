require 'compass-rails'
require 'sass-rails'
require 'csv'
require 'devise'
require 'dragonfly'
require 'scoped_search'
require 'acts-as-taggable-on'
require 'awesome_nested_set'
require 'kaminari'
require 'friendly_id'
require 'inherited_resources'
require 'has_scope'
require 'koi_config'
require 'simple_form'
require 'simple_navigation'
require 'uuidtools'
require 'redis'
require 'sinatra'
require 'sidekiq'
require 'sidekiq/web'
require 'select2-rails'
require 'activevalidators'
require 'rails-observers'
require 'cocoon'
require 'figaro'
require 'rickshaw_rails'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'has_crud/has_crud'
require 'has_navigation/has_navigation'
require 'has_settings/has_settings'
require 'arbre'
require 'koi/menu'
require 'koi/koi_asset'
require 'koi/koi_assets/image'
require 'koi/koi_assets/document'
require 'koi/settings'
require 'koi/sitemap'
require 'koi/caching'
require 'koi/engine'
require 'reports/reporting'
require 'koi/resource'
require 'koi/resource_actions'
require 'koi/router'
require 'koi/form_proxy'
require 'koi/components/index_as_table'

module Koi
  class << self
    def setup
      # Prevent auto loading of app/admin files as it will conflict with with
      # models as directories are loaded alphabetically and files are called the
      # same name.
      ActiveSupport::Dependencies.autoload_paths -= [Rails.root.join("app", "admin").to_s]
      Rails.application.config.eager_load_paths -= [Rails.root.join("app", "admin").to_s]

      yield
      load_resources
      attach_reloader
    end

    def router
      @router ||= Koi::Router.new
    end

    def reload!
      # Clear out old routes
      @router = Koi::Router.new
      # Reload resources
      load_resources
    end

    private

    def load_resources
      resources = Dir.glob(Rails.root.join("app", "admin", "*"))
      resources.each do |resource|
        load(resource)
      end
    end

    def attach_reloader
      Rails.application.config.after_initialize do |app|
        # resource_files = Dir.glob(Rails.root.join("app", "admin", "*")).map(&:to_s)
        # resource_reloader = app.config.file_watcher.new(resource_files, []) do
        # end

        # app.reloaders << resource_reloader

        ActionDispatch::Reloader.to_prepare do
          Koi.reload!
        end
      end
    end
  end
end

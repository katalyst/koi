# frozen_string_literal: true

require "rails/generators/named_base"
require "rails/generators/resource_helpers"

module Koi
  class AdminContentGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

    DEFAULT_MIGRATION_FORMAT = "%Y%m%d%H%M%S"

    source_root File.expand_path("templates", __dir__)

    check_class_collision prefix: "Admin::", suffix: "Controller"

    hook_for(:admin_route, in: :koi, type: :boolean, default: true)

    def create_controller_files
      create_content_controller_file
      create_content_controller_spec_file
      create_content_controller_route

      create_admin_controller_file
      create_admin_controller_spec_file
    end

    def create_model_files
      create_model_migration_file
      create_model_file
      create_model_factory_file
      create_model_spec_file
    end

    def create_view_files
      create_admin_view_files
      create_content_view_files
    end

    private

    def create_content_controller_file
      template("controllers/controller.rb",
               File.join("app/controllers",
                         controller_class_path,
                         "#{controller_file_name}_controller.rb"))

    end

    def create_content_controller_route
      routing_code = <<~ROUTE
        constraints #{controller_class_name}Controller::Constraints do
          resources :#{plural_name}, path: "", param: :slug, constraints: { format: :html } do
            get "preview", on: :member
          end
        end
        resolve("#{singular_name.camelcase}") { |#{singular_name}| #{singular_name}_path(#{singular_name}.slug) }
      ROUTE

      inject_into_file "config/routes.rb", routing_code,
                       after:   "Rails.application.routes.draw do\n",
                       verbose: true,
                       force:   false
    end

    def create_content_controller_spec_file
      template("controllers/controller_spec.rb",
               File.join("spec/requests",
                         controller_class_path,
                         "#{controller_file_name}_controller_spec.rb"))
    end

    def create_admin_controller_file
      template("controllers/admin/controller.rb",
               File.join("app/controllers/admin",
                         controller_class_path,
                         "#{controller_file_name}_controller.rb"))
    end

    def create_admin_controller_spec_file
      template("controllers/admin/controller_spec.rb",
               File.join("spec/requests/admin",
                         controller_class_path,
                         "#{controller_file_name}_controller_spec.rb"))
    end

    def create_model_migration_file(timestamp = Time.now.strftime(DEFAULT_MIGRATION_FORMAT))
      template("models/migration.rb",
               File.join("db/migrate/",
                         "#{timestamp}_create_#{plural_name}.rb"))
    end

    def create_model_file
      template("models/model.rb",
               File.join("app/models/",
                         "#{singular_name}.rb"))
    end

    def create_model_factory_file
      template("models/factory.rb",
               File.join("spec/factories/",
                         "#{plural_name}.rb"))
    end

    def create_model_spec_file
      template("models/model_spec.rb",
               File.join("spec/models/",
                         "#{singular_name}_spec.rb"))
    end

    def create_admin_view_files
      empty_directory File.join("app/views/admin", controller_file_path)

      available_admin_views.each do |filename|
        target = filename.gsub("record", singular_name)
        template "views/admin/#{filename}", File.join("app/views/admin", controller_file_path, target)
      end
    end

    def create_content_view_files
      empty_directory File.join("app/views", controller_file_path)

      available_content_views.each do |filename|
        target = filename.gsub("record", singular_name)
        template "views/#{filename}", File.join("app/views", controller_file_path, target)
      end
    end

    def available_admin_views
      %w[index.html.erb
         edit.html.erb
         show.html.erb
         new.html.erb
         _fields.html.erb
         _record.html+row.erb]
    end

    def available_content_views
      %w[show.html.erb]
    end
  end
end

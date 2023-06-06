# frozen_string_literal: true

require "rails/generators/active_record/model/model_generator"

module Koi
  class ScaffoldGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    def create_controller
      copy_file "app/controllers/admin/models_controller.rb", "app/controllers/admin/#{plural_name}_controller.rb"
      gsub_file "app/controllers/admin/#{plural_name}_controller.rb", "ModelsController",
                "#{plural_name.camelize}Controller"
      template "spec/requests/admin/models_controller_spec.rb.erb", "spec/requests/admin/#{plural_name}_controller_spec.rb"
    end

    def create_views
      directory "app/views/admin/model", "app/views/admin/#{plural_name}"
    end

    def create_route
      insert_into_file "config/routes/admin.rb", "  resources :#{plural_route_name}\n",
                       after: "namespace :admin do\n"
      insert_into_file "config/initializers/koi.rb",
                       "  \"#{human_name.pluralize}\" => \"/admin/#{plural_route_name}\",\n",
                       after: "Koi::Menu.modules = {\n"
    end

    # Replacing needles with locals from NamedBase.
    # Not using Thor's template method as these files contains erb code.
    def gsub_names
      Dir.glob(%W[app/views/admin/#{plural_name}/* app/controllers/admin/#{plural_name}_controller.rb]).each do |file|
        gsub_file(file, "HUMAN_NAME", human_name)
        gsub_file(file, "HUMAN_PLURAL_NAME", human_name.pluralize)
        gsub_file(file, "PLURAL_NAME", plural_name)
        gsub_file(file, "SINGULAR_NAME", singular_name)
        gsub_file(file, "CLASS_NAME", class_name)
      end
    end
  end
end

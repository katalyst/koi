# frozen_string_literal: true

require "rails/generators/active_record/model/model_generator"

module Koi
  class ScaffoldGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    def create_controller
      template("app/controllers/admin/models_controller.erb",
               "app/controllers/admin/#{plural_name}_controller.rb")
      template("spec/requests/admin/models_controller_spec.erb",
               "spec/requests/admin/#{plural_name}_controller_spec.rb")
    end

    def create_views
      directory("app/views/admin/model",
                "app/views/admin/#{plural_name}")
      Dir.glob(%W[app/views/admin/#{plural_name}/*]).each do |path|
        gsub_names(path)
      end
    end

    def create_route
      insert_into_file("config/routes/admin.rb",
                       "  resources :#{plural_route_name}\n",
                       after: "namespace :admin do\n")
      insert_into_file("config/initializers/koi.rb",
                       "  \"#{human_name.pluralize}\" => \"/admin/#{plural_route_name}\",\n",
                       after: "Koi::Menu.modules = {\n")
    end

    private

    # Replacing needles with locals from NamedBase.
    # Not using Thor's template method as these files contains erb code.
    def gsub_names(file)
      file = File.expand_path(file, destination_root)
      say_status :gsub, relative_to_original_destination_root(file)

      content = File.binread(file)
      content.gsub!("HUMAN_NAME", human_name)
      content.gsub!("HUMAN_PLURAL_NAME", human_name.pluralize)
      content.gsub!("PLURAL_NAME", plural_name)
      content.gsub!("SINGULAR_NAME", singular_name)
      content.gsub!("CLASS_NAME", class_name)
      File.open(file, "wb") { |file| file.write(content) }
    end
  end
end

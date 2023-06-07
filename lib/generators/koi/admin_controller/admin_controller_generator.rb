# frozen_string_literal: true

require "rails/generators/named_base"
require "rails/generators/resource_helpers"

module Koi
  class AdminControllerGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

    argument :attributes, type: :array, default: [], banner: "field:type field:type"
    source_root File.expand_path("templates", __dir__)

    def create_controller
      template("app/controllers/admin/models_controller.erb",
               "app/controllers/admin/#{plural_name}_controller.rb")
      template("spec/requests/admin/models_controller_spec.erb",
               "spec/requests/admin/#{plural_name}_controller_spec.rb")
    end

    def create_views
      directory("app/views/admin/model", "app/views/admin/#{plural_name}")
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

    def govuk_input_for(attribute)
      case attribute.type
      when :string
        %(<%= form.govuk_text_field :#{attribute.name}, label: { size: "s" } %>)
      when :integer
        %(<%= form.govuk_number_field :#{attribute.name}, label: { size: "s" } %>)
      when :boolean
        %(<%= form.govuk_check_box_field :#{attribute.name}, small: true, label: { size: "s" } %>)
      when :date
        %(<%= form.govuk_date_field :#{attribute.name}, legend: { size: "s" } %>)
      when :text
        %(<%= form.govuk_rich_text_area :#{attribute.name}, label: { size: "s" } %>)
      when :rich_text
        %(<%= form.govuk_rich_text_area :#{attribute.name}, label: { size: "s" } %>)
      else
        ""
      end
    end

    def permitted_params
      attachments, others = attributes_names.partition { |name| attachments?(name) }
      params = others.map { |name| ":#{name}" }
      params += attachments.map { |name| "#{name}: []" }
      params.join(", ")
    end

    def attachments?(name)
      attribute = attributes.find { |attr| attr.name == name }
      attribute&.attachments?
    end
  end
end

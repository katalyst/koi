# frozen_string_literal: true

require "rails/generators/named_base"
require "rails/generators/resource_helpers"

require_relative "../helpers/admin_generator_attributes"

module Koi
  class AdminControllerGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers
    include Helpers::AdminGeneratorAttributes

    source_root File.expand_path("templates", __dir__)

    check_class_collision prefix: "Admin::", suffix: "Controller"

    argument :attributes, type: :array, default: [], banner: "field:type field:type"

    def create_controller_files
      template("controller.rb",
               File.join("app/controllers",
                         controller_class_path,
                         "#{controller_file_name}_controller.rb"))
    end

    def create_spec_files
      template("controller_spec.rb",
               File.join("spec/requests",
                         controller_class_path,
                         "#{controller_file_name}_controller_spec.rb"))
    end

    hook_for(:admin_views, in: :koi, type: :boolean, default: true)
    hook_for(:admin_route, in: :koi, type: :boolean, default: true)

    private

    def controller_class_path
      ["admin"] + super
    end

    def permitted_params
      attachments, others = attributes_names.partition { |name| attachments?(name) }
      params              = others.map { |name| ":#{name}" }
      params += attachments.map { |name| "#{name}: []" }
      params.join(", ")
    end

    def attachments?(name)
      attribute = attributes.find { |attr| attr.name == name }
      attribute&.attachments?
    end

    def sort_attribute
      attributes.find { |attr| attr.type == :string }&.name
    end
  end
end

# frozen_string_literal: true

require "rails/generators/named_base"
require "rails/generators/resource_helpers"

require_relative "../helpers/admin_generator_attributes"

module Koi
  class AdminViewsGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers
    include Helpers::AdminGeneratorAttributes

    source_root File.expand_path("templates", __dir__)

    argument :attributes, type: :array, default: [], banner: "field:type field:type"

    def create_root_folder
      empty_directory File.join("app/views", controller_file_path)
    end

    def copy_view_files
      available_views.each do |filename|
        target = filename.gsub("record", singular_name)
        template filename, File.join("app/views", controller_file_path, target)
      end
    end

    private

    def available_views
      %w(index.html.erb edit.html.erb show.html.erb new.html.erb _fields.html.erb)
    end

    def controller_class_path
      ["admin"] + super
    end
  end
end

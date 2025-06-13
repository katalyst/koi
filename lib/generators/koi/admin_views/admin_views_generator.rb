# frozen_string_literal: true

require "rails/generators/named_base"

require_relative "../helpers/attribute_helpers"
require_relative "../helpers/resource_helpers"

module Koi
  class AdminViewsGenerator < Rails::Generators::NamedBase
    include Helpers::AttributeHelpers
    include Helpers::ResourceHelpers

    source_root File.expand_path("templates", __dir__)

    argument :attributes, type: :array, default: [], banner: "field:type field:type"

    def create_root_folder
      empty_directory File.join("app/views", controller_file_path)
    end

    def copy_view_files
      available_views.each do |filename|
        template(filename, File.join("app/views", controller_file_path, filename))
      end
    end

    def remove_legacy
      remove_file(File.join("app/views", controller_file_path, "_fields.html.erb"), force: true)
    end

    private

    def available_views
      %w(index.html.erb edit.html.erb show.html.erb new.html.erb _form.html.erb)
    end
  end
end

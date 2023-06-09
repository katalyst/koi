# frozen_string_literal: true

require "rails/generators/named_base"
require "rails/generators/resource_helpers"

module Koi
  class AdminViewsGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

    source_root File.expand_path("templates", __dir__)

    argument :attributes, type: :array, default: [], banner: "field:type field:type"

    def create_root_folder
      empty_directory File.join("app/views/admin", controller_file_path)
    end

    def copy_view_files
      available_views.each do |view|
        filename = "#{view}.html.erb"
        template filename, File.join("app/views/admin", controller_file_path, filename)
      end
    end

    private

    def available_views
      %w(index edit show new _fields)
    end

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
      when :attachment
        if attribute.name.include?("image")
          %(<%= form.govuk_image_field :#{attribute.name},
            label: { size: "s", text: "#{attribute.name.humanize}" }, hint: { max_size: 10.megabytes } %>)
        else
          %(<%= form.govuk_document_field :#{attribute.name},
            label: { size: "s", text: "#{attribute.name.humanize}" }, hint: { max_size: 10.megabytes } %>)
        end
      else
        ""
      end
    end

    def index_attributes
      attributes.select { |attribute| attribute.type == :string }.take(3)
    end
  end
end

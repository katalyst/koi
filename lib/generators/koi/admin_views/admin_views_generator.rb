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
      available_views.each do |filename|
        target = filename.gsub("record", singular_name)
        template filename, File.join("app/views/admin", controller_file_path, target)
      end
    end

    private

    def available_views
      %w(index.html.erb edit.html.erb show.html.erb new.html.erb _fields.html.erb _record.html+row.erb)
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
      else
        ""
      end
    end

    def index_attributes
      attributes.select { |attribute| attribute.type == :string }.take(3)
    end
  end
end

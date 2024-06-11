# frozen_string_literal: true

require "rails/generators/named_base"
require "rails/generators/resource_helpers"

module Koi
  class AdminViewsGenerator < Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

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

    def govuk_input_for(attribute)
      case attribute.type
      when :string
        %(<%= form.govuk_text_field :#{attribute.name} %>)
      when :integer
        %(<%= form.govuk_number_field :#{attribute.name} %>)
      when :boolean
        %(<%= form.govuk_check_box_field :#{attribute.name} %>)
      when :date
        %(<%= form.govuk_date_field :#{attribute.name}, legend: { size: "s" } %>)
      when :rich_text, :text
        %(<%= form.govuk_rich_text_area :#{attribute.name} %>)
      when :attachment
        %(<%= form.govuk_image_field :#{attribute.name} %>)
      else
        ""
      end
    end

    def summary_attribute_for(attribute)
      case attribute.type
      when :string
        %(<% dl.text :#{attribute.name} %>)
      when :integer
        %(<% dl.number :#{attribute.name} %>)
      when :boolean
        %(<% dl.boolean :#{attribute.name} %>)
      when :date
        %(<% dl.date :#{attribute.name} %>)
      when :datetime
        %(<% dl.datetime :#{attribute.name} %>)
      when :rich_text
        %(<% dl.rich_text :#{attribute.name} %>)
      when :attachment
        %(<% dl.attachment :#{attribute.name} %>)
      else
        %(<% dl.text :#{attribute.name} %>)
      end
    end

    def index_attribute_for(attribute)
      case attribute.type
      when :integer
        %(<% row.number :#{attribute.name} %>)
      when :boolean
        %(<% row.boolean :#{attribute.name} %>)
      when :date
        %(<% row.date :#{attribute.name} %>)
      when :datetime
        %(<% row.datetime :#{attribute.name} %>)
      when :rich_text
        %(<% row.rich_text :#{attribute.name} %>)
      when :attachment
        %(<% row.attachment :#{attribute.name} %>)
      else
        %(<% row.text :#{attribute.name} %>)
      end
    end

    def index_attributes
      attributes
    end
  end
end

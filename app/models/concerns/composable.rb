module Composable
  extend ActiveSupport::Concern

  included do

    def composable_data
      if defined?(super)
        super
      else
        raise "You need a jsonb field called `composable_data` in the model implementing this concern"
      end
    end

    def composable?
      composable_json.present?
    end

    def composable_json
      if composable_data.present?
        JSON.parse(composable_data)
      end
    end

    def composable_sections
      Composable.format_composable_data(composable_data) if composable?
    end

    def composable_sections_with_drafts
      Composable.format_composable_data(composable_data, include_drafts: true) if composable?
    end

  end

  class_methods do
    def composable_field_types
      # Try getting settings from crud config
      self.crud.settings.try(:[], :admin).try(:[], :form).try(:[], :composable) ||

      # Fallback to defaults
      [:section, :heading, :text]
    end

    # Take the composable_field_types and retrieve the config from the library
    def composable_config
      Koi::ComposableContent.components.select { |type| self.composable_field_types.include?(type[:slug].to_sym) }
    end
  end

  # When you add a field type to a page, but don't specify a
  # section, use this hash to override what section it gets
  # wrapped in
  def self.field_type_section_fallbacks
    {
      "video": "fullscreen",
      "full_banner": "fullscreen"
    }
  end

  def self.format_composable_data(data, include_drafts: false)
    # Group page sections as nested data
    current_composable_section = false
    composable_sections = []
    if data.is_a?(String)
      data = JSON.parse(data)
    end
    if data.present?
      data.each_with_index do |datum,index|
        next if !include_drafts && datum["component_draft"].eql?(true)

        # create new section if there is no current section and this
        # isn't a new section
        if !current_composable_section && !datum["component_type"].eql?("section")
          current_composable_section = {
            section_type: field_type_section_fallbacks[datum[:component_type]] || Koi::ComposableContent.fallback_section_type,
            section_data: []
          }
        end
        # create a new section if this is a new section
        if datum["component_type"].eql?("section")
          # push current page section to page sections if there's one available
          composable_sections << current_composable_section if current_composable_section
          # create a new section from this datum
          current_composable_section = {
            section_type: datum["data"]["section_type"] || Koi::ComposableContent.fallback_section_type,
            section_data: []
          }
        # push datum to current page section
        else
          current_composable_section[:section_data] << datum.except!("component_collapsed", "id")
        end
      end
      # push last section to composable_sections
      if current_composable_section && !composable_sections.include?(current_composable_section)
        composable_sections << current_composable_section
      end
      composable_sections
    end
  end

end

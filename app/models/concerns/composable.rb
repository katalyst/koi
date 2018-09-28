module Composable
  extend ActiveSupport::Concern

  #
  # TO USE:
  #
  # include this module in any model
  # add to fields:
  #            composable_data: { type: :composable }
  # add to form fields:
  #           :composable_data
  # Render wherever needed:
  # <% if resource.composable? %>
  #  <%= render 'shared/composables', data: resource.composable_sections %>
  # <% end %>
  #

  included do

    def composable_data
      if defined?(super)
        super
      else
        raise "You need a jsonb field called `composable_data` in the model implementing this concern"
      end
    end

    def composable?
      composable_data.present?
    end

    def composable_json
      if composable_data.present?
        JSON.parse(composable_data)
      end
    end

    def composable_sections
      Composable.format_composable_data(composable_data) if composable?
    end

  end

  class_methods do
    def composable_field_types
      # Try getting settings from crud config
      self.crud.settings.try(:[], :admin).try(:[], :form).try(:[], :composable) ||
      
      # Fallback to defaults
      ["section", "heading", "text"]
    end

    # Take the composable_field_types and retrieve the config from the library
    def composable_config
      Koi::ComposableContent::COMPONENTS.select { |type| self.composable_field_types.include?(type[:slug]) }
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

  def self.format_composable_data(data)
    # Group page sections as nested data
    current_composable_section = false
    composable_sections = []
    if data.is_a?(String)
      data = JSON.parse(data)
    end
    if data["data"].present?
      data["data"].each_with_index do |datum,index|
        # create new section if there is no current section and this
        # isn't a new section
        if !current_composable_section && !datum["type"].eql?("section")
          current_composable_section = {
            section_type: field_type_section_fallbacks[datum[:type]] || "body",
            section_data: []
          }
        end
        # create a new section if this is a new section
        if datum["type"].eql?("section")
          # push current page section to page sections if there's one available
          composable_sections << current_composable_section if current_composable_section
          # create a new section from this datum
          current_composable_section = {
            section_type: datum["section_type"] || "body",
            section_data: []
          }
        # push datum to current page section
        else
          current_composable_section[:section_data] << datum
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

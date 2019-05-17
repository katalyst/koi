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

    # Get all raw JSON data
    # resource.composable_json => { main: [...] }
    # Optionally get all raw JSON data for a specific group by
    # passing in a group key
    # resource.composable_json(:main) => [...]
    def composable_json(group=false)
      data = composable_data
      if data.present?
        data = JSON.parse(data)
        data = data[group.to_s] if group
        data
      end
    end

    # Get formatted composable content grouped in to sections for a specific group
    # resource.composable_sections(:main)
    def composable_sections(group)
      Composable.format_composable_data(composable_data, group) if composable?
    end

    # Same as composable_sections but includes drafts
    def composable_sections_with_drafts(group)
      Composable.format_composable_data(composable_data, group, include_drafts: true) if composable?
    end

  end

  class_methods do
    def composable_crud_config
      # Try getting settings from crud config
      self.crud.settings.try(:[], :admin).try(:[], :form).try(:[], :composable) ||

      # Fallback to defaults
      {
        main: [:section, :heading, :text],
      }
    end

    # Take the composable_field_types and retrieve the config from the library
    def composable_config
      config = composable_crud_config
      structure = {}
      config.each do |group, fields|
        structure[group] = Koi::ComposableContent.components.select { |type| fields.include?(type[:slug].to_sym) }
      end
      structure
    end
  end

  # When you add a component to a page, but don't specify a
  # section, use this hash to override what section it gets
  # wrapped in
  def self.component_type_section_fallbacks
    {
      "video": "fullwidth",
      "full_banner": "fullwidth",
    }
  end

  def self.format_composable_data(data, group, include_drafts: false)
    # Group page sections as nested data
    current_composable_section = false
    composable_sections = []
    if data.is_a?(String)
      data = JSON.parse(data)
    end
    if data.present?
      # Select the group
      data = data[group.to_s]
      data.each_with_index do |datum,index|
        next if !include_drafts && datum["component_draft"].eql?(true)

        # create new section if there is no current section and this
        # isn't a new section
        if !current_composable_section && !datum["component_type"].eql?("section")
          current_composable_section = {
            section_type: component_type_section_fallbacks[datum[:component_type]] || Koi::ComposableContent.fallback_section_type,
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
            section_data: [],
            section_draft: datum["component_draft"],
            advanced: datum["advanced"] || {},
          }
        # push datum to current page section
        else
          # Mark as draft if section is a draft
          if Koi::ComposableContent.section_drafting_for_children
            datum["component_draft"] = current_composable_section[:section_draft] if current_composable_section[:section_draft]
          end
          current_composable_section[:section_data] << datum.except!("component_collapsed")
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

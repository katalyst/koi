#
# PURPOSE:
#
# Manages components usable by the composable content field type
#
# USAGE:
#
# In your app (in an initializer) you can register a component for use in composable pages content like so:
#
# Koi::ComposableContent.register_component { name: "Section", slug: "section", fields: [ ... ] }
#
#
# You can register multiple components with Koi::ComposableContent.register_components
#
#
module Koi
  class ComposableContent

    def self.register_component(component)
      @@components ||= {}
      @@components[component[:name]] = component
    end

    def self.register_components(components)
      components.each{ |component| register_component(component) }
    end

    def self.components
      @@components.values
    end

    # Default fallacbk section type when no initial section type
    # is used in composition
    def self.fallback_section_type
      @@fallback_section_type ||= "body"
    end

    # Method to change initial section type
    # Koi::ComposableContent.fallback_section_type = "my_custom_fallback"
    def self.fallback_section_type=(section_type)
      @@fallback_section_type = section_type
    end

    # Method for injecting new section types without having to override
    # the entire component
    def self.section_types=(section_types)
      component = @@components["Section"].try(:[], :fields).try(:[], 0)
      if component.present?
        component[:data] = section_types
      end
    end

    # Setting for marking children of sections as draft when sections
    # are draft
    def self.section_drafting_for_children
      @@section_drafting_for_children
    end

    def self.section_drafting_for_children=(setting)
      @@section_drafting_for_children = setting
    end

    # Setting for enabling / disabling the advanced settings
    # menu in components
    def self.advanced_settings
      @@advanced_settings
    end

    def self.advanced_settings=(settings)
      @@advanced_settings = settings
    end

    # Initialise settings
    @@advanced_settings = [{
      name: "class",
      label: "Class",
    },{
      name: "id",
      label: "Id",
      hint: "This can be used for anchoring purposes",
    }]
    @@section_drafting_for_children = true

    #
    # Register the default components we want in koi.
    # THese can be replaced by registering a component with the same name.
    #
    register_components [
        {
          label: "Section",
          name: "section",
          nestable: true,
          icon: "composable_section",
          primary: "section_type",
          fields: [
            {
              label: "Section Type",
              name: "section_type",
              type: "select",
              className: "form--auto",
              data: ["body", "fullwidth"],
            }
          ]
        },

        {
          label: "Heading",
          name: "heading",
          icon: "heading",
          primary: "text",
          fields: [
            {
              label: "Heading Text",
              name: "text",
              type: "string",
              className: "form--medium"
            },
            {
              label: "Size",
              name: "heading_size",
              type: "select",
              data: ["2", "3", "4", "5", "6"],
              className: "form--auto"
            }
          ]
        },

        {
          label: "Text",
          name: "text",
          icon: "paragraph",
          primary: "body",
          fields: [
            {
              name: "body",
              type: "textarea"
            }
          ]
        },

        {
          label: "Rich Text",
          name: "rich_text",
          icon: "paragraph_with_image",
          primary: "body",
          fields: [
            {
              name: "body",
              type: "rich_text"
            }
          ]
        },
      ]

  end
end

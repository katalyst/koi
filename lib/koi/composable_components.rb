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

    #
    # Register the default components we want in koi.
    # THese can be replaced by registering a component with the same name.
    #
    register_components [
        {
          name: "Section",
          slug: "section",
          nestable: true,
          icon: "composable_section",
          primary: "section_type",
          fields: [
            {
              label: "Section Type",
              name: "section_type",
              type: "select",
              className: "form--auto",
              data: ["body", "fullwidth"]
            }
          ]
        },

        {
          name: "Heading",
          slug: "heading",
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
          name: "Text",
          slug: "text",
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
          name: "Rich Text",
          slug: "rich_text",
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

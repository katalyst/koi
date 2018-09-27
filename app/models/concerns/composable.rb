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
      Composable.composable_field_types
    end
    
    def composable_config
      Composable.composable_library.select { |type| self.composable_field_types.include?(type[:slug]) }
    end
  end

  # Overridable field types
  def self.composable_field_types
    ["section", "heading", "text"]
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

  # TODO: Relocate somewhere easily editable - initialiser? constant? etc
  def self.composable_library
    [
      {
        name: "Section",
        slug: "section",
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
        fields: [
          {
            name: "body",
            type: "textarea"
          }
        ]
      },
      {
        name: "Hero",
        slug: "hero",
        fields: [
          {
            name: "hero_id",
            type: "select",
            label: "Superhero",
            className: "form--auto",
            data: [{ name: "", value: "" }] + SuperHero.all.map { |hero| { name: hero.name, value: hero.id } },
            fieldAttributes: {
              required: true
            }
          },
          {
            name: "image_size",
            type: "select",
            label: "Image size",
            defaultValue: "120x120#",
            data: [
              {
                name: "None",
                value: "none"
              },{
                name: "Small",
                value: "80x80#"
              },{
                name: "Medium",
                value: "120x120#"
              },{
                name: "Large",
                value: "250x250#"
              }
            ]
          },{
            name: "show_link",
            type: "boolean",
            label: "Show link to hero page",
            defaultValue: true
          }
        ]
      },
      {
        name: "Kitchen Sink",
        slug: "kitchen_sink",
        fields: [
          {
            name: "small_field",
            label: "Small Field",
            hint: "This field has a hint",
            type: "string",
            className: "form--small",
            fieldAttributes: {
              required: true
            }
          },
          {
            name: "medium_field",
            label: "Medium Field",
            placeholder: "This field has a placeholder",
            type: "string",
            className: "form--medium"
          },{
            name: "large_field",
            label: "Large Field",
            defaultValue: "This field has a default value",
            type: "string",
            className: "form--large"
          },{
            name: "date",
            label: "Datepicker",
            hint: "Only future dates",
            placeholder: "Choose a date",
            type: "date",
            inputData: {
              "datepicker-mindate": 0
            }
          },{
            name: "colour",
            label: "Colourpicker",
            type: "colour"
          },{
            name: "text",
            label: "Textarea",
            type: "textarea"
          },{
            name: "rich_text",
            label: "WYSIWYG Editor",
            type: "rich_text"
          },{
            name: "number",
            label: "Number Field",
            type: "number"
          },{
            name: "range",
            label: "Range Field",
            hint: "Min of 10, max of 200",
            type: "range",
            fieldAttributes: {
              min: 10,
              max: 200
            }
          },{
            name: "boolean",
            label: "Boolean",
            type: "boolean"
          },{
            name: "boolean_checked",
            label: "Boolean (Checked by default)",
            defaultValue: true,
            type: "boolean"
          },{
            name: "checkboxes",
            label: "Checkbox Collection",
            hint: "Collection of options with multiple selections",
            type: "check_boxes",
            data: ["Option 1", "Option 2", "Option 3"]
          },{
            name: "checkboxes_horizontal",
            label: "Checkbox Collection (Horizontal)",
            hint: "Collection of options with multiple selections",
            wrapperClass: "form--horizontal",
            type: "check_boxes",
            data: ["Option 1", "Option 2", "Option 3"]
          },{
            name: "radios",
            label: "Radios",
            hint: "Collection of options with one selection",
            type: "radio_buttons",
            data: ["Option 1", "Option 2", "Option 3"]
          },{
            name: "select_array",
            label: "Select (Array)",
            type: "select",
            data: ["Option 1", "Option 2", "Option 3"]
          },{
            name: "select_object",
            label: "Select (Object)",
            hint: "These options have different values to their labels",
            type: "select",
            data: [
              { 
                name: "Option 1", 
                value: 1
              },
              {
                name: "Option 2",
                value: 2
              },
              {
                name: "Option 3",
                value: 3
              }
            ]
          }
        ]
      }
    ]
  end

end

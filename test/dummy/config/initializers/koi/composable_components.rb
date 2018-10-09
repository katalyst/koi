module Koi
  module ComposableContent

    COMPONENTS =
      [

        {
          name: "Section",
          slug: "section",
          nestable: true,
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
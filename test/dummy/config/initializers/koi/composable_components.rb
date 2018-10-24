Koi::ComposableContent.register_components [

  {
    name: "Reaptable thing",
    slug: "repeatable_thing",
    icon: "paragraph_with_image",
    fields: [
      {
        name: "name",
        label: "Name of thing",
        type: "string",
      },
      {
        name: "items",
        label: "Items",
        type: "repeater",
        fields: [{
          name: "name",
          label: "Item Name",
          type: "string",
        },{
          name: "number",
          label: "Item Number",
          type: "string",
        }]
      }
    ]
  },

  {
    name: "Text with image",
    slug: "text_with_image",
    icon: "paragraph",
    primary: 'text',
    fields: [
      {
        name: "text",
        type: "textarea",
      },
      {
        name: "image",
        type: 'image',
      }
    ]
  },
  {
    name: "Hero",
    slug: "hero",
    icon: "user",
    primary: "hero_id",
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
    name: "Hero List",
    slug: "hero_list",
    icon: "listing_blocks",
    primary: "list_type",
    fields: [
      {
        name: "list_type",
        type: "select",
        label: "List Type",
        className: "form--auto",
        data: ["", "Male", "Female"],
      },
    ]
  },

  {
    name: "Kitchen Sink",
    slug: "kitchen_sink",
    icon: "stack",
    primary: "small_field",
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

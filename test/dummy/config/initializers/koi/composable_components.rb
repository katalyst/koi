# Koi::ComposableContent.show_advanced_settings = false
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
        validations: ["atLeastOne"],
        fields: [{
          name: "name",
          label: "Item Name",
          type: "string",
          validations: ["required"],
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
    validations: ["anyValues"],
    fields: [
      {
        name: "text",
        type: "textarea",
        label: "Text",
      },
      {
        name: "image_id",
        type: 'asset',
        label: "Image",
      }
    ]
  },

  {
    name: "Autocompletes",
    slug: "autocompletes",
    primary: "hero_id",
    message: "Make sure you have Super Hero data",
    messageType: "passive",
    fields: [
      {
        name: "hero_id",
        type: "autocomplete",
        label: "Hardcoded data - Superheroes",
        hint: "Example of hardcoded data showing label, saving value. Same as select menu just with autocomplete",
        data: [{ label: "", value: "" }] + SuperHero.all.map { |hero| { label: hero.name, value: hero.id } },
      },
      {
        name: "hero_search_name",
        type: "autocomplete",
        label: "AJAX superhero name",
        hint: "An example of looking up and saving string data (eg. no association)",
        searchEndpoint: "/admin/super_heros/name_search",
      },
      {
        name: "hero_search_id",
        type: "autocomplete",
        label: "AJAX superhero id",
        hint: "An example of looking up and saving an id and displaying the name in the field",
        searchEndpoint: "/admin/super_heros/search_id",
        contentEndpoint: "/admin/super_heros/content_id",
      },
      {
        name: "hero_ajax_association",
        type: "autocomplete",
        label: "AJAX Superhero association",
        hint: "An example of saving a record type and record id (eg. psuedo-association)",
        searchEndpoint: "/admin/super_heros/search_association",
        contentEndpoint: "/admin/super_heros/content_association",
        withRecordType: true,
      }
    ]
  },

  {
    name: "No Config",
    slug: "no_config",
  },

  {
    name: "Hero",
    slug: "hero",
    icon: "user",
    primary: "hero_id",
    fields: [
      {
        name: "hero_id",
        type: "autocomplete",
        label: "Superhero",
        data: [{ label: "", value: "" }] + SuperHero.all.map { |hero| { label: hero.name, value: hero.id } },
      },
      {
        name: "image_size",
        type: "select",
        label: "Image size",
        defaultValue: "120x120#",
        data: [
          {
            label: "None",
            value: "none"
          },{
            label: "Small",
            value: "80x80#"
          },{
            label: "Medium",
            value: "120x120#"
          },{
            label: "Large",
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
            label: "Option 1",
            value: 1
          },
          {
            label: "Option 2",
            value: 2
          },
          {
            label: "Option 3",
            value: 3
          }
        ]
      }
    ]
  }
]

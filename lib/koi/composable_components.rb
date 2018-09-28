module Koi
  module ComposableContent

    COMPONENTS =
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
        }
        
      ]

  end
end
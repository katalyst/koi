# frozen_string_literal: true

module Koi
  module Tables
    module Body
      # Shows Yes/No for boolean values
      class BooleanComponent < BodyCellComponent
        def rendered_value
          value ? "Yes" : "No"
        end
      end

      # Formats the value as a date
      # default format is :admin
      class DateComponent < BodyCellComponent
        def initialize(table, record, attribute, format: :admin, **options)
          super(table, record, attribute, **options)

          @format = format
        end

        def rendered_value
          value.present? ? l(value.to_date, format: @format) : ""
        end
      end

      # Formats the value as a datetime
      # default format is :admin
      class DatetimeComponent < BodyCellComponent
        def initialize(table, record, attribute, format: :admin, **options)
          super(table, record, attribute, **options)

          @format = format
        end

        def rendered_value
          value.present? ? l(value.to_datetime, format: @format) : ""
        end
      end

      # Formats the value as a money value
      # The value is expected to be in cents
      # Adds a class to the cell to allow for custom styling
      class MoneyComponent < BodyCellComponent
        def rendered_value
          value.present? ? number_to_currency(value / 100.0) : ""
        end

        def default_html_attributes
          { class: "number" }
        end
      end

      # Formats the value as a number
      # Adds a class to the cell to allow for custom styling
      class NumberComponent < BodyCellComponent
        def rendered_value
          value.present? ? number_to_human(value) : ""
        end

        def default_html_attributes
          { class: "number" }
        end
      end

      # Displays the plain text for rich text content
      # Adds a title attribute to allow for hover over display of the full content
      class RichTextComponent < BodyCellComponent
        def rendered_value
          value.to_plain_text
        end

        def default_html_attributes
          { title: rendered_value }
        end
      end

      # Displays a link to the record
      # The link text is the value of the attribute
      # The link url can be configured, defaults to the admin show path for the record
      class LinkComponent < BodyCellComponent
        def rendered_value
          value.present? ? link_to(value, url_for([:admin, object])) : ""
        end
      end

      # Shows a thumbnail image
      # The value is expected to be an ActiveStorage attachment with a variant named :thumb
      class ImageComponent < BodyCellComponent
        def initialize(table, record, attribute, variant: :thumb, **options)
          super(table, record, attribute, **options)

          @variant = variant
        end

        def rendered_value
          value.present? ? image_tag(value.variant(@variant)) : ""
        end
      end
    end
  end
end

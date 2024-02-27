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
      #
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
      #
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
      #
      # The value is expected to be in cents.
      # Adds a class to the cell to allow for custom styling
      class CurrencyComponent < BodyCellComponent
        def initialize(table, record, attribute, options: {}, **html_attributes)
          super(table, record, attribute, **html_attributes)

          @options = options
        end

        def rendered_value
          value.present? ? number_to_currency(value / 100.0, @options) : ""
        end

        def default_html_attributes
          { class: "koi--tables-col-currency" }
        end
      end

      # Formats the value as a number
      #
      # Adds a class to the cell to allow for custom styling
      class NumberComponent < BodyCellComponent
        def rendered_value
          value.present? ? number_to_human(value) : ""
        end

        def default_html_attributes
          { class: "koi--tables-col-number" }
        end
      end

      # Displays the plain text for rich text content
      #
      # Adds a title attribute to allow for hover over display of the full content
      class RichTextComponent < BodyCellComponent
        def default_html_attributes
          { title: value.to_plain_text }
        end
      end

      # Displays a link to the record
      #
      # Link options can be passed in to customise the link,
      # the link text is the value of the attribute
      #
      # @see Koi::Tables::BodyRowComponent#link
      class LinkComponent < BodyCellComponent
        def initialize(table, record, attribute, link: {}, **html_attributes)
          super(table, record, attribute, **html_attributes)

          @url_builder = link.delete(:url) || ->(object) { [:admin, object] }
          @link_options = link
        end

        def call
          content # ensure content is set before rendering options

          link = content.present? && url.present? ? link_to(content, url, @link_options) : content.to_s
          content_tag(@type, link, **html_attributes)
        end

        def url
          @url ||= if @url_builder.is_a?(Symbol)
                     helpers.public_send(@url_builder, record)
                   else
                     @url_builder.call(record)
                   end
        end
      end

      # Shows a thumbnail image
      #
      # The value is expected to be an ActiveStorage attachment with a default variant named :thumb
      class ImageComponent < BodyCellComponent
        def initialize(table, record, attribute, variant: :thumb, **options)
          super(table, record, attribute, **options)

          @variant = variant
        end

        def rendered_value
          value.present? ? image_tag(value.variant(@variant)) : ""
        end
      end

      # Shows an attachment in a cell
      #
      # If it is representable, shows as a image tag(assumes a variant called :thumb is defined for the attachment)
      #
      # Otherwise shows as a link to download
      class AttachmentComponent < BodyCellComponent
        def rendered_value
          if value.representable?
            image_tag(value.variant(:thumb))
          else
            link_to value.blob.filename, rails_blob_path(value, disposition: :attachment)
          end
        end
      end
    end
  end
end

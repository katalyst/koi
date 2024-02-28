# frozen_string_literal: true

using Katalyst::HtmlAttributes::HasHtmlAttributes

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
      # @param format [String] date format, defaults to :admin
      # @param relative [Boolean] if true, the date may be(if within 5 days) shown as a relative date
      class DateComponent < BodyCellComponent
        include Koi::DateHelper

        def initialize(table, record, attribute, format: :admin, relative: true, **options)
          super(table, record, attribute, **options)

          @format   = format
          @relative = relative
        end

        def value
          super&.to_date
        end

        def rendered_value
          @relative ? relative_time : absolute_time
        end

        private

        def absolute_time
          value.present? ? I18n.l(value, format: @format) : ""
        end

        def relative_time
          if value.blank?
            ""
          else
            days_ago_in_words(value)&.capitalize || absolute_time
          end
        end

        def default_html_attributes
          @relative && value.present? && days_ago_in_words(value).present? ? { title: absolute_time } : {}
        end
      end

      # Formats the value as a datetime
      # @param format [String] datetime format, defaults to :admin
      # @param relative [Boolean] if true, the datetime may be(if today) shown as a relative date/time
      class DatetimeComponent < BodyCellComponent
        include ActionView::Helpers::DateHelper

        def initialize(table, record, attribute, format: :admin, relative: true, **options)
          super(table, record, attribute, **options)

          @format   = format
          @relative = relative
        end

        def value
          super&.to_datetime
        end

        def rendered_value
          @relative ? relative_time : absolute_time
        end

        private

        def absolute_time
          value.present? ? I18n.l(value, format: @format) : ""
        end

        def today?
          value.to_date == Date.current
        end

        def relative_time
          return "" if value.blank?

          if today?
            if value > DateTime.current
              "#{distance_of_time_in_words(value, DateTime.current)} from now".capitalize
            else
              "#{distance_of_time_in_words(value, DateTime.current)} ago".capitalize
            end
          else
            absolute_time
          end
        end

        def default_html_attributes
          @relative && today? ? { title: absolute_time } : {}
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
          super.merge_html(class: "type-currency")
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
          super.merge_html(class: "type-number")
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
      # The link text is the value of the attribute
      # @see Koi::Tables::BodyRowComponent#link
      class LinkComponent < BodyCellComponent
        def initialize(table, record, attribute, url:, link: {}, **options)
          super(table, record, attribute, **options)

          @url = url
          @link_options = link
        end

        def call
          content # ensure content is set before rendering options

          link = content.present? && url.present? ? link_to(content, url, @link_options) : content.to_s
          content_tag(@type, link, **html_attributes)
        end

        def url
          case @url
          when Symbol
            # helpers are not available until the component is rendered
            @url = helpers.public_send(@url, record)
          when Proc
            @url = @url.call(record)
          else
            @url
          end
        end
      end

      # Shows an attachment
      #
      # The value is expected to be an ActiveStorage attachment
      #
      # If it is representable, shows as a image tag using a default variant named :thumb.
      #
      # Otherwise shows as a link to download.
      class AttachmentComponent < BodyCellComponent
        def initialize(table, record, attribute, variant: :thumb, **options)
          super(table, record, attribute, **options)

          @variant = variant
        end

        def rendered_value
          if value.try(:representable?)
            image_tag(@variant.nil? ? value : value.variant(@variant))
          elsif value.try(:attached?)
            link_to value.blob.filename, rails_blob_path(value, disposition: :attachment)
          else
            ""
          end
        end
      end
    end
  end
end

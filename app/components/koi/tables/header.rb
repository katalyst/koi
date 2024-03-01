# frozen_string_literal: true

using Katalyst::HtmlAttributes::HasHtmlAttributes

module Koi
  module Tables
    module Header
      class NumberComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-number")
        end
      end

      class CurrencyComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-currency")
        end
      end

      class BooleanComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-boolean")
        end
      end

      class DateComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-date")
        end
      end

      class DateTimeComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-datetime")
        end
      end

      class LinkComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-link")
        end
      end

      class TextComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-text")
        end
      end

      class ImageComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-image")
        end
      end

      class AttachmentComponent < HeaderCellComponent
        def default_html_attributes
          super.merge_html(class: "type-attachment")
        end
      end
    end
  end
end

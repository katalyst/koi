# frozen_string_literal: true

module Koi
  module Tables
    module Header
      class NumberComponent < HeaderCellComponent
        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def initialize(table, attribute, label: nil, link: {}, width: :xs, **html_attributes)
          super(table, attribute, label:, link:, width:, **html_attributes)
        end

        def default_html_attributes
          super.merge_html(class: "koi--tables-col-number")
        end
      end

      class CurrencyComponent < HeaderCellComponent
        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def initialize(table, attribute, label: nil, link: {}, width: :s, **html_attributes)
          super(table, attribute, label:, link:, width:, **html_attributes)
        end

        def default_html_attributes
          super.merge_html(class: "koi--tables-col-currency")
        end
      end

      class BooleanComponent < HeaderCellComponent
        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def initialize(table, attribute, label: nil, link: {}, width: :xs, **html_attributes)
          super(table, attribute, label:, link:, width:, **html_attributes)
        end

        def default_html_attributes
          super.merge_html(class: "koi--tables-col-boolean")
        end
      end

      class DateComponent < HeaderCellComponent
        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def initialize(table, attribute, label: nil, link: {}, width: :s, **html_attributes)
          super(table, attribute, label:, link:, width:, **html_attributes)
        end

        def default_html_attributes
          super.merge_html(class: "koi--tables-col-date")
        end
      end

      class DateTimeComponent < HeaderCellComponent
        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def initialize(table, attribute, label: nil, link: {}, width: :m, **html_attributes)
          super(table, attribute, label:, link:, width:, **html_attributes)
        end

        def default_html_attributes
          super.merge_html(class: "koi--tables-col-datetime")
        end
      end

      class LinkComponent < HeaderCellComponent
        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def default_html_attributes
          super.merge_html(class: "koi--tables-col-link")
        end
      end

      class TextComponent < HeaderCellComponent
        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def default_html_attributes
          super.merge_html(class: "koi--tables-col-text")
        end
      end

      class ImageComponent < HeaderCellComponent
        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def default_html_attributes
          super.merge_html(class: "koi--tables-col-image")
        end
      end

      class AttachmentComponent < HeaderCellComponent
        using Katalyst::HtmlAttributes::HasHtmlAttributes

        def default_html_attributes
          super.merge_html(class: "koi--tables-col-attachment")
        end
      end
    end
  end
end

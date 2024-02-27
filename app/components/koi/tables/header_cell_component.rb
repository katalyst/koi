# frozen_string_literal: true

module Koi
  module Tables
    class HeaderCellComponent < Katalyst::Tables::HeaderCellComponent
      using Katalyst::HtmlAttributes::HasHtmlAttributes

      attr_reader :width

      def initialize(table, attribute, label: nil, link: {}, width: nil, **html_attributes)
        @width = width

        super(table, attribute, label:, link:, **html_attributes)
      end

      def default_html_attributes
        super.merge_html(class: width_class)
      end

      private

      def width_class
        case width
        when :xs
          "koi--tables-col-xs"
        when :s
          "koi--tables-col-s"
        when :m
          "koi--tables-col-m"
        when :l
          "koi--tables-col-l"
        else
          ""
        end
      end
    end
  end
end

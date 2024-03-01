# frozen_string_literal: true

using Katalyst::HtmlAttributes::HasHtmlAttributes

module Koi
  module Tables
    class HeaderCellComponent < Katalyst::Tables::HeaderCellComponent
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
          "width-xs"
        when :s
          "width-s"
        when :m
          "width-m"
        when :l
          "width-l"
        else
          ""
        end
      end
    end
  end
end

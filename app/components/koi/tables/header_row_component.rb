# frozen_string_literal: true

module Koi
  module Tables
    # Custom header row component, in order to override the default header cell component
    # for number columns, we add a class to the header cell to allow for custom styling
    class HeaderRowComponent < Katalyst::Tables::HeaderRowComponent
      def boolean(attribute, **attributes, &block)
        header_cell(attribute, **attributes, &block)
      end

      def date(attribute, **attributes, &block)
        header_cell(attribute, **attributes, &block)
      end

      def datetime(attribute, **attributes, &block)
        header_cell(attribute, **attributes, &block)
      end

      def number(attribute, **attributes, &block)
        header_cell(attribute, **attributes, component: Header::NumberComponent, &block)
      end

      def money(attribute, **attributes, &block)
        header_cell(attribute, **attributes, component: Header::NumberComponent, &block)
      end

      def rich_text(attribute, **attributes, &block)
        header_cell(attribute, **attributes, &block)
      end

      def link(attribute, **attributes, &block)
        header_cell(attribute, **attributes, &block)
      end

      def attachment(attribute, **attributes, &block)
        header_cell(attribute, type: :link, **attributes, &block)
      end

      def text(attribute, **attributes, &block)
        header_cell(attribute, **attributes, &block)
      end

      def image(attribute, **attributes, &block)
        header_cell(attribute, **attributes, &block)
      end

      private

      def header_cell(attribute, component: HeaderCellComponent, **attributes, &block)
        with_column(component.new(@table, attribute, link: @link_attributes, **attributes), &block)
      end
    end
  end
end

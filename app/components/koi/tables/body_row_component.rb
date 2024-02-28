# frozen_string_literal: true

module Koi
  module Tables
    # Custom body row component, in order to override the default body cell component
    class BodyRowComponent < Katalyst::Tables::BodyRowComponent
      def boolean(attribute, **options, &block)
        with_column(Body::BooleanComponent.new(@table, @record, attribute, **options), &block)
      end

      def date(attribute, format: :admin, **options, &block)
        with_column(Body::DateComponent.new(@table, @record, attribute, format:, **options), &block)
      end

      def datetime(attribute, format: :admin, **options, &block)
        with_column(Body::DatetimeComponent.new(@table, @record, attribute, format:, **options), &block)
      end

      def number(attribute, **options, &block)
        with_column(Body::NumberComponent.new(@table, @record, attribute, **options), &block)
      end

      def money(attribute, **options, &block)
        with_column(Body::MoneyComponent.new(@table, @record, attribute, **options), &block)
      end

      def rich_text(attribute, **options, &block)
        with_column(Body::RichTextComponent.new(@table, @record, attribute, **options), &block)
      end

      def link(attribute, url: [:admin, @record], link: {}, **attributes, &block)
        with_column(Body::LinkComponent.new(@table, @record, attribute, url:, link:, **attributes), &block)
      end

      def text(attribute, **options, &block)
        with_column(BodyCellComponent.new(@table, @record, attribute, **options), &block)
      end

      def attachment(attribute, variant: :thumb, **options, &block)
        with_column(Body::AttachmentComponent.new(@table, @record, attribute, variant:, **options), &block)
      end
    end
  end
end

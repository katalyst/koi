# frozen_string_literal: true

module Koi
  module SummaryList
    class Base < ViewComponent::Base
      include Katalyst::HtmlAttributes

      define_html_attribute_methods :term_attributes, default: {}
      define_html_attribute_methods :description_attributes, default: {}

      def initialize(model, attribute, label: nil, skip_blank: true)
        super()

        @model      = model
        @attribute  = attribute
        @label      = label
        @skip_blank = skip_blank
      end

      def call
        tag.dt(attribute_name, **term_attributes) +
          tag.dd(content_or_value, **description_attributes)
      end

      def render?
        raw_value.present? || !@skip_blank
      end

      def attribute_name
        @label&.dig(:text) || @model.class.human_attribute_name(@attribute)
      end

      def attribute_value
        raw_value.to_s
      end

      def raw_value
        @model.public_send(@attribute)
      end

      def inspect
        "#<#{self.class.name} #{@attribute.inspect}>"
      end

      # Convenience method for rendering the content of the cell
      # <% dl.text(:name) { |cell| tag.em(cell) } %>
      # => <dt>Name</dt><dd><em>Jamie Banks</em></dd>
      def to_s
        attribute_value
      end

      private

      def content_or_value
        content? ? content : attribute_value
      end
    end
  end
end

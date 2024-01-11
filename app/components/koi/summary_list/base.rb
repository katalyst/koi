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
        tag.dt(attribute_name, **term_attributes) + tag.dd(attribute_value, **description_attributes)
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
    end
  end
end

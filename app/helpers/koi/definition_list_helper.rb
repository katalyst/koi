# frozen_string_literal: true

module Koi
  module DefinitionListHelper
    def definition_list(**options, &block)
      DefinitionListBuilder.new(self).render(**options, &block)
    end
  end

  class DefinitionListBuilder
    delegate_missing_to :@context

    def initialize(context)
      @context = context
    end

    def render(**options, &block)
      tag.dl class: options.delete(:class) do
        concat(capture { yield self }) if block
      end
    end

    def items_with(model:, attributes:, **options)
      attributes.each do |attribute|
        concat item(model, attribute, **options)
      end
    end

    def item(object, attribute, **options)
      Definition.new(@context, object, attribute).render(**options)
    end

    class Definition
      attr_reader :object, :attribute

      delegate_missing_to :@context

      def initialize(context, object, attribute)
        @context   = context
        @object    = object
        @attribute = attribute
      end

      def render(**options)
        return unless render?(**options)

        term_tag(**options) + definition_tag(**options)
      end

      private

      def render?(**options)
        !(options[:skip_blank] && attribute_value.blank?)
      end

      def term_tag(**options)
        tag.dt label_for(**options)
      end

      def definition_tag(**_options)
        case attribute_value
        when Array
          tag.dd(attribute_value.join(", "))
        else
          tag.dd(attribute_value)
        end
      end

      def label_for(**options)
        options.dig(:label, :text) ||
          t(attribute, scope: object.model_name.param_key.to_sym, default: attribute.to_s.humanize)
      end

      def attribute_value
        @attribute_value ||= object.public_send(attribute).to_s
      end
    end
  end
end

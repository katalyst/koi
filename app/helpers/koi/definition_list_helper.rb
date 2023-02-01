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
      capture do
        attributes.each do |attribute|
          concat item(model, attribute, **options)
        end
      end
    end

    def item(object, attribute, **options, &block)
      Definition.new(@context, object, attribute).render(**options, &block)
    end

    class Definition
      attr_reader :object, :attribute

      delegate_missing_to :@context

      def initialize(context, object, attribute)
        @context   = context
        @object    = object
        @attribute = attribute
      end

      def render(**options, &block)
        return unless render?(**options)

        term_tag(**options) + definition_tag(&block)
      end

      private

      def render?(**options)
        !(options[:skip_blank] && attribute_value.blank? && attribute_value != false)
      end

      def term_tag(**options)
        tag.dt label_for(**options)
      end

      def definition_tag(&block)
        if block
          tag.dd { yield attribute_value }
        else
          case attribute_value
          when Array
            tag.dd(attribute_value.join(", "))
          when ActiveStorage::Attached::One
            tag.dd(attribute_value.attached? ? link_to(attribute_value.filename, url_for(attribute_value)) : "")
          else
            tag.dd(attribute_value.to_s)
          end
        end
      end

      def label_for(**options)
        options.dig(:label, :text) || object.class.human_attribute_name(attribute)
      end

      def attribute_value
        @attribute_value ||= object.public_send(attribute)
      end
    end
  end
end

# frozen_string_literal: true

module Koi
  module DefinitionListHelper
    def definition_list(**options, &)
      DefinitionListBuilder.new(self, options).render(&)
    end
  end

  class DefinitionListBuilder
    delegate_missing_to :@context

    def initialize(context, options = {})
      @context = context
      @options = options
    end

    def render(&block)
      tag.dl class: @options.delete(:class) do
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

    def item(object, attribute, **options, &)
      Definition.new(@context, object, attribute, **@options, **options).render(&)
    end

    class Definition
      attr_reader :object, :attribute, :options

      delegate_missing_to :@context

      def initialize(context, object, attribute, options = {})
        @context   = context
        @object    = object
        @attribute = attribute
        @options   = options
      end

      def render(&)
        return unless render?

        term_tag + definition_tag(&)
      end

      private

      def render?
        !(options.fetch(:skip_blank, true) && attribute_value.blank? && attribute_value != false)
      end

      def term_tag
        tag.dt(label)
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
          when Date, Time, DateTime
            tag.dd(l(attribute_value, format: :short))
          when TrueClass, FalseClass
            tag.dd(attribute_value ? "Yes" : "No")
          else
            tag.dd(attribute_value.to_s)
          end
        end
      end

      def label
        options.dig(:label, :text) || object.class.human_attribute_name(attribute)
      end

      def attribute_value
        @attribute_value ||= object.public_send(attribute)
      end
    end
  end
end

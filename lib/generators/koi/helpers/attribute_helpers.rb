# frozen_string_literal: true

require "rails/generators/resource_helpers"

require_relative "attribute_types"

module Koi
  module Helpers
    module AttributeHelpers
      extend ActiveSupport::Concern

      included do
        private

        def parse_attributes!
          if attributes.none? && model_class && model_class < ActiveRecord::Base
            load_attributes!
          else
            super
          end
        end
      end

      class IntrospectedAttribute < Rails::Generators::GeneratedAttribute
        attr_reader :association, :attachment, :enum

        def initialize(name, type, association: nil, attachment: nil, enum: nil, **)
          super(name, type, **)

          @association = association
          @attachment = attachment
          @enum = enum
        end

        def association?
          @association.present?
        end

        def attachment?
          @attachment.present?
        end

        def enum?
          @enum.present?
        end
      end

      def govuk_input_for(attribute)
        AttributeTypes.for(attribute).govuk_input
      end

      def index_attribute_for(attribute)
        AttributeTypes.for(attribute).index_row
      end

      def show_attribute_for(attribute)
        AttributeTypes.for(attribute).show_row
      end

      def collection_attribute_for(attribute)
        AttributeTypes.for(attribute).collection_attribute
      end

      def index_attributes
        attributes.select { |attribute| index_attribute_for(attribute).present? }
      end

      def show_attributes
        attributes.select { |attribute| show_attribute_for(attribute).present? }
      end

      def default_sort_attribute
        if orderable?
          :ordinal
        elsif (attribute = attributes.find { |attr| attr.type == :string })
          attribute.name
        else
          attributes.first&.name
        end
      end

      private

      def model_class
        @model_class ||= class_name.safe_constantize
      end

      def load_attributes!
        load_basic_attributes!
        load_attachment_attributes!
        load_rich_text_attributes!
        load_association_attributes!
      end

      def load_basic_attributes!
        model_class.attribute_types.each do |name, type|
          next if internal_column?(name) || foreign_key_column?(name)

          @attributes << IntrospectedAttribute.new(name, type.type, enum: model_class.defined_enums[name])
        end
      end

      def load_attachment_attributes!
        return unless model_class.respond_to?(:attachment_reflections)

        model_class.attachment_reflections.each do |name, attachment|
          @attributes << IntrospectedAttribute.new(name, :attachment, attachment:)
        end
      end

      def load_rich_text_attributes!
        return unless model_class.respond_to?(:rich_text_association_names)

        model_class.rich_text_association_names.each do |name|
          @attributes << IntrospectedAttribute.new(name.to_s.gsub(/^rich_text_/, "").to_sym, :rich_text)
        end
      end

      def load_association_attributes!
        model_class.reflect_on_all_associations.each do |association|
          next unless association.macro == :belongs_to

          @attributes << IntrospectedAttribute.new(
            association.name.to_s,
            :string, # associations display as text/links
            association:,
          )
        end
      end

      def attachments?(name)
        attribute = attributes.find { |attr| attr.name == name }
        attribute&.attachments?
      end

      def internal_column?(name)
        %w[id created_at updated_at].include?(name.to_s)
      end

      def foreign_key_columns
        model_class
          .reflect_on_all_associations(:belongs_to)
          .map(&:foreign_key)
      end

      def foreign_key_column?(name)
        foreign_key_columns.include?(name.to_s)
      end
    end
  end
end

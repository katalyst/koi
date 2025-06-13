# frozen_string_literal: true

module Koi
  module Helpers
    module AttributeTypes
      class Base
        attr_reader :attribute

        def initialize(attribute)
          @attribute = attribute
        end

        def govuk_input
          nil
        end

        def index_row
          nil
        end

        def show_row
          nil
        end

        def collection_attribute
          nil
        end
      end

      class StringType < Base
        def govuk_input
          %(<%= form.govuk_text_field :#{attribute.name} %>)
        end

        def index_row
          %(<% row.text :#{attribute.name} %>)
        end

        def show_row
          %(<% row.text :#{attribute.name} %>)
        end

        def collection_attribute
          %(attribute :#{attribute.name}, :string)
        end
      end

      class IntegerType < Base
        def govuk_input
          %(<%= form.govuk_number_field :#{attribute.name} %>)
        end

        def index_row
          %(<% row.number :#{attribute.name} %>)
        end

        def show_row
          %(<% row.number :#{attribute.name} %>)
        end

        def collection_attribute
          %(attribute :#{attribute.name}, :integer)
        end
      end

      class BooleanType < Base
        def govuk_input
          %(<%= form.govuk_check_box_field :#{attribute.name} %>)
        end

        def index_row
          %(<% row.boolean :#{attribute.name} %>)
        end

        def show_row
          %(<% row.boolean :#{attribute.name} %>)
        end

        def collection_attribute
          %(attribute :#{attribute.name}, :boolean)
        end
      end

      class DateType < Base
        def govuk_input
          %(<%= form.govuk_date_field :#{attribute.name} %>)
        end

        def index_row
          %(<% row.date :#{attribute.name} %>)
        end

        def show_row
          %(<% row.date :#{attribute.name} %>)
        end

        def collection_attribute
          %(attribute :#{attribute.name}, :date)
        end
      end

      class DatetimeType < Base
        def index_row
          %(<% row.datetime :#{attribute.name} %>)
        end

        def show_row
          %(<% row.datetime :#{attribute.name} %>)
        end

        def collection_attribute
          %(attribute :#{attribute.name}, :date)
        end
      end

      class RichTextType < Base
        def govuk_input
          %(<%= form.govuk_rich_text_area :#{attribute.name} %>)
        end

        def show_row
          %(<% row.rich_text :#{attribute.name} %>)
        end
      end

      class AttachmentType < Base
        def govuk_input
          %(<%= form.govuk_image_field :#{attribute.name} %>)
        end

        def show_row
          %(<% row.attachment :#{attribute.name} %>)
        end
      end

      class AssociationType < Base
        def show_row
          %(<% row.link :#{attribute.name} %>)
        end
      end

      class EnumType < Base
        def govuk_input
          %(<%= form.govuk_enum_select :#{attribute.name} %>)
        end

        def index_row
          %(<% row.enum :#{attribute.name} %>)
        end

        def show_row
          %(<% row.enum :#{attribute.name} %>)
        end

        def collection_attribute
          %(attribute :#{attribute.name}, :enum)
        end
      end

      class OrdinalType < Base
      end

      class ArchivedType < Base
        def show_row
          %(<% row.boolean :archived %>)
        end
      end

      module GeneratedAttributeExtensions
        refine Rails::Generators::GeneratedAttribute do
          def attachment?
            false
          end

          def association?
            %i[belongs_to references].include?(type)
          end

          def enum?
            false
          end
        end
      end

      TYPES = {
        string:     StringType,
        integer:    IntegerType,
        boolean:    BooleanType,
        date:       DateType,
        datetime:   DatetimeType,
        rich_text:  RichTextType,
        text:       StringType,
        attachment: AttachmentType,
        enum:       EnumType,
      }.freeze

      using GeneratedAttributeExtensions

      def for(attribute)
        if attribute.association?
          AssociationType.new(attribute)
        elsif attribute.attachment?
          AttachmentType.new(attribute)
        elsif attribute.enum?
          EnumType.new(attribute)
        elsif attribute.name == "ordinal"
          OrdinalType.new(attribute)
        elsif attribute.name == "archived_at"
          ArchivedType.new(attribute)
        else
          TYPES.fetch(attribute.type, StringType).new(attribute)
        end
      end

      module_function :for
    end
  end
end

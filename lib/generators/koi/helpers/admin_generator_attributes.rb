# frozen_string_literal: true

module Koi
  module Helpers
    module AdminGeneratorAttributes
      extend ActiveSupport::Concern

      def govuk_input_for(attribute)
        case attribute.type
        when :string
          %(<%= form.govuk_text_field :#{attribute.name} %>)
        when :integer
          %(<%= form.govuk_number_field :#{attribute.name} %>)
        when :boolean
          %(<%= form.govuk_check_box_field :#{attribute.name} %>)
        when :date
          %(<%= form.govuk_date_field :#{attribute.name}, legend: { size: "s" } %>)
        when :rich_text, :text
          %(<%= form.govuk_rich_text_area :#{attribute.name} %>)
        when :attachment
          %(<%= form.govuk_image_field :#{attribute.name} %>)
        else
          ""
        end
      end

      def index_attribute_for(attribute)
        case attribute.type
        when :integer
          %(<% row.number :#{attribute.name} %>)
        when :boolean
          %(<% row.boolean :#{attribute.name} %>)
        when :date
          %(<% row.date :#{attribute.name} %>)
        when :datetime
          %(<% row.datetime :#{attribute.name} %>)
        when :rich_text
          %(<% row.rich_text :#{attribute.name} %>)
        when :attachment
          %(<% row.attachment :#{attribute.name} %>)
        else
          %(<% row.text :#{attribute.name} %>)
        end
      end

      alias_method :summary_attribute_for, :index_attribute_for

      def collection_attribute_for(attribute)
        case attribute.type
        when :string
          %(attribute :#{attribute.name}, :string)
        when :integer
          %(attribute :#{attribute.name}, :integer)
        when :boolean
          %(attribute :#{attribute.name}, :boolean)
        when :date, :datetime
          %(attribute :#{attribute.name}, :date)
        end
      end

      def index_attributes
        attributes
      end
    end
  end
end

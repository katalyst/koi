# frozen_string_literal: true

module Koi
  module SummaryList
    class NumberComponent < Base
      def initialize(model, attribute, format: :admin, **options)
        super(model, attribute, **options)

        @format = format
      end

      def attribute_value
        number_to_human(raw_value) if raw_value.present?
      end

      def default_description_attributes
        { class: "number" }
      end
    end
  end
end

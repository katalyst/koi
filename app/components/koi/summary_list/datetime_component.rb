# frozen_string_literal: true

module Koi
  module SummaryList
    class DatetimeComponent < Base
      def initialize(model, attribute, format: :admin, **options)
        super(model, attribute, **options)

        @format = format
      end

      def attribute_value
        l(raw_value.to_datetime, format: @format) if raw_value.present?
      end
    end
  end
end

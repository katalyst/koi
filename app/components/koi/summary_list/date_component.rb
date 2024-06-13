# frozen_string_literal: true

module Koi
  module SummaryList
    class DateComponent < Base
      def initialize(model, attribute, format: :admin, **)
        super(model, attribute, **)

        @format = format
      end

      def attribute_value
        l(raw_value.to_date, format: @format) if raw_value.present?
      end
    end
  end
end

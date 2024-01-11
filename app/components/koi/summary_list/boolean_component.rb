# frozen_string_literal: true

module Koi
  module SummaryList
    class BooleanComponent < Base
      def render?
        true
      end

      def attribute_value
        raw_value ? "Yes" : "No"
      end
    end
  end
end

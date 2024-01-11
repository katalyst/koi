# frozen_string_literal: true

module Koi
  module SummaryList
    class RichTextComponent < Base
      def attribute_value
        raw_value
      end
    end
  end
end

# frozen_string_literal: true

module Koi
  module SummaryList
    class ItemComponent < Base
      def render?
        !(@skip_blank && raw_value.blank? && raw_value != false)
      end

      def attribute_value
        case raw_value
        when Array
          raw_value.join(", ")
        when ActiveStorage::Attached::One
          raw_value.attached? ? link_to(raw_value.filename, url_for(raw_value)) : ""
        when Date, Time, DateTime, ActiveSupport::TimeWithZone
          l(raw_value, format: :admin)
        when TrueClass, FalseClass
          raw_value ? "Yes" : "No"
        else
          raw_value.to_s
        end
      end
    end
  end
end

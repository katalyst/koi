# frozen_string_literal: true

module Koi
  module DateHelper
    def distance_from_now
      from_time = value.to_time
      to_time = Date.current.to_time
      distance_in_days = ((to_time - from_time) / (24.0 * 60.0 * 60.0)).round

      case distance_in_days
      when 0
        "today"
      when 1
        "yesterday"
      when -1
        "tomorrow"
      when 2..5
        "#{distance_in_days} days ago"
      when -5..-2
        "#{distance_in_days.abs} days from now"
      end
    end
  end
end

# frozen_string_literal: true

module Koi
  # Koi Pagy extensions
  module Pagy
    module Frontend
      private

      # @overload nav_aria_label() to add stimulus controller to pagy_nav
      def nav_aria_label(pagy, aria_label: nil)
        "#{super} data-controller='pagy-nav'"
      end
    end
  end
end

# frozen_string_literal: true

module Koi
  class TrixToolbarComponent < ViewComponent::Base
    include Katalyst::HtmlAttributes

    define_html_attribute_methods :button_row_attributes

    def initialize(button_row_attributes:, **)
      super(**)

      @button_row_attributes = button_row_attributes
    end

    def default_html_attributes
      {
        class: "koi-trix-toolbar",
      }
    end

    def default_button_row_attributes
      {
        class: "trix-button-row",
      }
    end
  end
end

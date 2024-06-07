# frozen_string_literal: true

module Koi
  class FilterComponent < ViewComponent::Base
    include Katalyst::HtmlAttributes
    include Turbo::FramesHelper

    define_html_attribute_methods :input_attributes
    define_html_attribute_methods :form_attributes

    def initialize(model:, collection:)
      super()

      @model      = model
      @collection = collection
    end

    def default_html_attributes
      {
        id:   "filter",
        data: {
          action:       <<~ACTIONS,
            submit->filter--form#submit
          ACTIONS
          controller:   "filter--popper filter--form",
          turbo_action: "replace",
        },
      }
    end

    def default_input_attributes
      {
        data: {
          filter__form_target:   "input",
          filter__popper_target: "input",
          action:                <<~ACTIONS,
            input->filter--form#update
            change->filter--form#update
            focus->filter--popper#focus
            blur->filter--popper#blur
          ACTIONS
        },
      }
    end

    def filter_path
      helpers.admin_filter_path(@model)
    end
  end
end

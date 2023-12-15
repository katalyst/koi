# frozen_string_literal: true

module Koi
  module Navigation
    module Editor
      class ErrorsComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes
        include Katalyst::Tables::TurboReplaceable
        include Turbo::FramesHelper

        attr_reader :menu

        def initialize(menu:)
          super()

          @menu = menu
        end

        def id
          dom_id(menu, :errors)
        end

        def form_builder
          Koi::FormBuilder.new(menu.model_name.param_key, container, self, {})
        end
      end
    end
  end
end

# frozen_string_literal: true

module Koi
  module Content
    module Editor
      class ErrorsComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes
        include Turbo::FramesHelper

        attr_reader :container

        def initialize(container:)
          super()

          @container = container
        end

        def id
          dom_id(container, :errors)
        end

        def form_builder
          Koi::FormBuilder.new(container.model_name.param_key, container, self, {})
        end
      end
    end
  end
end

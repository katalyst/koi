# frozen_string_literal: true

module Katalyst
  module Navigation
    module Editor
      class Errors < Base
        def build(**options)
          turbo_frame_tag dom_id(menu, :errors) do
            form_builder.govuk_error_summary(**options)
          end
        end

        private

        def form_builder
          GOVUKDesignSystemFormBuilder::FormBuilder.new(menu.model_name.param_key, menu, self, {})
        end
      end
    end
  end
end

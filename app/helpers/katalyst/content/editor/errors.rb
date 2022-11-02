# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class Errors < Base
        def build(**options)
          turbo_frame_tag dom_id(container, :errors) do
            form_builder.govuk_error_summary(**options)
          end
        end

        private

        def form_builder
          GOVUKDesignSystemFormBuilder::FormBuilder.new(container.model_name.param_key, container, self, {})
        end
      end
    end
  end
end

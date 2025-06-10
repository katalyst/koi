# frozen_string_literal: true

module Koi
  module FormHelper
    # Ensure that admin forms use `admin_` path helpers.
    def form_with(model: false, url: nil, format: nil, **, &)
      if model && (url != false)
        url ||= if format.nil?
                  polymorphic_path([:admin, model], {})
                else
                  polymorphic_path([:admin, model], format: format)
                end
      end

      super
    end
  end
end

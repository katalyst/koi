# frozen_string_literal: true

module Koi
  module Extensions
    module Dartsass
      extend ActiveSupport::Concern

      included do
        module_function

        # Removes gem `build` directories from dartsass load path. This ensures
        # that css assets will not take precedence over scss assets of the same
        # name.
        def dartsass_load_paths
          [::Dartsass::Runner::CSS_LOAD_PATH]
            .concat(Rails.application.config.assets.paths)
            .reject { |path| %r{app/assets/builds$}.match?(path.to_s) }
            .flat_map { |path| ["--load-path", path.to_s] }
        end
      end
    end
  end
end

# frozen_string_literal: true

module Koi
  module StyleguideHelper
    # Render source code
    def render_source(code)
      h(code&.to_param)
    end
  end
end

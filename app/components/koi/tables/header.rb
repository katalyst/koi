# frozen_string_literal: true

module Koi
  module Tables
    module Header
      class NumberComponent < HeaderCellComponent
        def default_html_attributes
          { class: "number" }
        end
      end
    end
  end
end

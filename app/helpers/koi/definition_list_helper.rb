# frozen_string_literal: true

module Koi
  module DefinitionListHelper
    # @deprecated This method is deprecated and will be removed in Koi 5.
    def definition_list(**options, &block)
      render Koi::SummaryListComponent.new(**options), &block
    end
  end
end

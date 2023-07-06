# frozen_string_literal: true

module Koi
  module Filters
    class SearchComponent < ViewComponent::Base
      attr_accessor :form

      def initialize(form)
        @form = form
      end

      def call
        form.search_field(:search, placeholder:, data:)
      end

      def placeholder
        t("koi.labels.search", default: "Search")
      end

      def data
        {
          index_actions_target: "search",
          actions:              <<~ACTIONS,
            shortcut:cancel@document->index-actions#clear
            shortcut:search@document->index-actions#search
          ACTIONS
        }
      end
    end
  end
end

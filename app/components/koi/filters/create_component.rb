# frozen_string_literal: true

module Koi
  module Filters
    class CreateComponent < ViewComponent::Base
      attr_accessor :form

      def initialize(form, path:)
        @form = form
        @path = path
      end

      def call
        tag.button(label, type: :submit, formaction:, class: "button--primary", data:)
      end

      def label
        t("koi.labels.new", default: "New")
      end

      def formaction
        @path.nil? ? view_context.url_for(action: :new) : view_context.new_polymorphic_path(@path)
      end

      def data
        {
          index_actions_target: "create",
          actions:              <<~ACTIONS,
            shortcut:create@document->index-actions#create
          ACTIONS
        }
      end
    end
  end
end

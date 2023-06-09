# frozen_string_literal: true

module Koi
  module Header
    class NewComponent < ViewComponent::Base
      attr_reader :model

      delegate :with_breadcrumb, :with_action, to: :@header

      def initialize(model:, title: nil)
        super

        @model  = model
        @title  = title

        @header = HeaderComponent.new(title: self.title)
      end

      def call
        render @header do |header|
          # render block, if any (delegating slots to header)
          content

          # add our breadcrumbs and actions
          add_index(header)
        end
      end

      def title
        @title || "New #{model.model_name.human.downcase}"
      end

      def add_index(header)
        header.with_breadcrumb(model.model_name.human.pluralize, url_for(action: :index))
      rescue ActionController::UrlGenerationError
        nil
      end
    end
  end
end

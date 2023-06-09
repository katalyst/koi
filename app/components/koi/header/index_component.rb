# frozen_string_literal: true

module Koi
  module Header
    class IndexComponent < ViewComponent::Base
      attr_reader :model

      delegate :with_breadcrumb, :with_action, to: :@header

      def initialize(model:, title: model.model_name.human.pluralize)
        super

        @header = HeaderComponent.new(title:)
        @model  = model
        @title  = title
      end

      def call
        render @header.with_content(content || "")
      end
    end
  end
end

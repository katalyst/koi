# frozen_string_literal: true

module Koi
  module Header
    class ShowComponent < ViewComponent::Base
      attr_reader :resource

      delegate :with_breadcrumb, :with_action, to: :@header

      def initialize(resource:, title: nil)
        super

        @title    = title
        @resource = resource

        @header = HeaderComponent.new(title: self.title)
      end

      def call
        render @header do |header|
          # render block, if any (delegating slots to header)
          content

          # add our breadcrumbs and actions
          add_index(header)
          add_edit(header)
        end
      end

      def title
        title = Koi.config.resource_name_candidates.reduce(@title) do |name, key|
          name || resource.respond_to?(key) && resource.public_send(key)
        end

        title.presence || resource.model_name.human
      end

      def add_index(header)
        header.with_breadcrumb(resource.model_name.human.pluralize, url_for(action: :index))
      end

      def add_edit(header)
        header.with_action("Edit", url_for(action: :edit))
      rescue ActionController::UrlGenerationError
        nil
      end
    end
  end
end

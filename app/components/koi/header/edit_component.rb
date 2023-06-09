# frozen_string_literal: true

module Koi
  module Header
    class EditComponent < ViewComponent::Base
      attr_reader :model, :resource

      delegate :with_breadcrumb, :with_action, to: :@header

      def initialize(resource:, title: nil)
        super

        @resource = resource
        @title = title

        @header = HeaderComponent.new(title: self.title)
      end

      def call
        render @header do |header|
          # capture nested component
          @header = header

          # render block, if any (delegating slots to header)
          content

          # add our breadcrumbs and actions
          add_index(header)
          add_show(header)
        end
      end

      def title
        @title || "Edit #{resource.model_name.human.downcase}"
      end

      def resource_title
        title = Koi.config.resource_name_candidates.reduce(nil) do |name, key|
          name || resource.respond_to?(key) && resource.public_send(key)
        end

        title.presence || resource.model_name.human
      end

      def add_index(header)
        header.with_breadcrumb(resource.model_name.human.pluralize, url_for(action: :index))
      rescue ActionController::UrlGenerationError
        nil
      end

      def add_show(header)
        header.with_breadcrumb(resource_title, url_for(action: :show))
      rescue ActionController::UrlGenerationError
        nil
      end
    end
  end
end

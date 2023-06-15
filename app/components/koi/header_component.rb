# frozen_string_literal: true

module Koi
  class HeaderComponent < ViewComponent::Base
    renders_many :actions, "LinkComponent"
    renders_many :breadcrumbs, "LinkComponent"

    def initialize(title:)
      @title = title
    end

    class LinkComponent < ViewComponent::Base
      def initialize(name, path, **options)
        @name    = name
        @path    = path
        @options = options
      end

      def call
        link_to @name, @path, **@options
      end
    end
  end
end
